import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { hashPassword } from '@/lib/auth';
import { UserRole } from '@prisma/client';

export async function POST(request: Request) {
  try {
    const body = await request.json();

    const {
      email,
      password,
      displayName,
      country,
      role, // "PILOT" o "MANAGER"
    } = body as {
      email?: string;
      password?: string;
      displayName?: string;
      country?: string;
      role?: 'PILOT' | 'MANAGER';
    };

    // Validaciones básicas
    if (!email || !password || !displayName || !role) {
      return NextResponse.json(
        { error: 'Faltan campos obligatorios.' },
        { status: 400 }
      );
    }

    if (!['PILOT', 'MANAGER'].includes(role)) {
      return NextResponse.json(
        { error: 'Rol no válido.' },
        { status: 400 }
      );
    }

    // Comprobar si ya existe un usuario con ese email
    const existing = await prisma.user.findUnique({
      where: { email },
    });

    if (existing) {
      return NextResponse.json(
        { error: 'Ya existe una cuenta con ese email.' },
        { status: 400 }
      );
    }

    // Hashear contraseña
    const hashedPassword = await hashPassword(password);

    // Crear el usuario
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        displayName,
        country,
        role: role as UserRole,
      },
    });

    // Si el rol es PILOT, crear también el perfil Pilot
    if (role === 'PILOT') {
      await prisma.pilot.create({
        data: {
          userId: user.id,
          name: displayName,
          country: country ?? 'Unknown',
          // el resto de campos (irating, sr, etc.) usan sus defaults
        },
      });
    }

    return NextResponse.json(
      { message: 'Usuario registrado correctamente.', userId: user.id },
      { status: 201 }
    );
  } catch (error) {
    console.error('Error en registro:', error);
    return NextResponse.json(
      { error: 'Error interno en el servidor.' },
      { status: 500 }
    );
  }
}
