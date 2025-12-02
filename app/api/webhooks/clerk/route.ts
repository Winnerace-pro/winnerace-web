import { Webhook } from "svix";
import prisma from "@/lib/prisma";
import { clerkClient } from "@clerk/nextjs/server";
import { headers } from "next/headers";

export async function POST(req: Request) {
  const WEBHOOK_SECRET = process.env.CLERK_WEBHOOK_SECRET;

  if (!WEBHOOK_SECRET) {
    console.error("❌ Falta CLERK_WEBHOOK_SECRET");
    return new Response("Falta CLERK_WEBHOOK_SECRET", { status: 500 });
  }

  // Next.js 16 — headers() devuelve una PROMESA
  const hdrs = await headers();

  const svixHeaders = {
    "svix-id": hdrs.get("svix-id") || "",
    "svix-timestamp": hdrs.get("svix-timestamp") || "",
    "svix-signature": hdrs.get("svix-signature") || "",
  };

  // Body como texto (requerido por svix)
  const body = await req.text();

  const wh = new Webhook(WEBHOOK_SECRET);

  let evt: any;
  try {
    evt = wh.verify(body, svixHeaders);
  } catch (err) {
    console.error("❌ Webhook verification failed", err);
    return new Response("Invalid signature", { status: 400 });
  }

  const type = evt.type;
  const data = evt.data;

  console.log("📩 Webhook recibido:", type);

  // ---------- USER CREATED ----------
  if (type === "user.created") {
    const email =
      data.email_addresses?.[0]?.email_address ??
      data.primary_email_address?.email_address ??
      null;

    if (!email) {
      console.error("❌ Webhook sin email");
      return new Response("Missing email", { status: 400 });
    }

    // Crear User en DB
    const newUser = await prisma.user.create({
      data: {
        email,
        role: "PILOT",
      },
    });

    // Crear Pilot asociado
    await prisma.pilot.create({
      data: {
        userId: newUser.id,
        name: data.username ?? email,
        country: data.public_metadata?.country ?? "Unknown",
      },
    });

    console.log("✅ Usuario + Pilot creados:", email);
  }

  return new Response("OK", { status: 200 });
}




