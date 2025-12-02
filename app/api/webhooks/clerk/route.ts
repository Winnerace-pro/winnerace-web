export const dynamic = "force-dynamic";

import { Webhook } from "svix";
import prisma from "@/lib/prisma";

export async function POST(req: Request) {
  try {
    // Leer headers directo del request (Next 16 compatible)
    const svix_id = req.headers.get("svix-id");
    const svix_signature = req.headers.get("svix-signature");
    const svix_timestamp = req.headers.get("svix-timestamp");

    if (!svix_id || !svix_signature || !svix_timestamp) {
      return new Response("Missing Svix headers", { status: 400 });
    }

    const payload = await req.text();

    // Validar firma
    const wh = new Webhook(process.env.CLERK_WEBHOOK_SECRET!);

    const evt = wh.verify(payload, {
      "svix-id": svix_id,
      "svix-signature": svix_signature,
      "svix-timestamp": svix_timestamp,
    }) as any;

    // ──────────────────────────────────────
    // Extraer email correctamente de Clerk
    // ──────────────────────────────────────

    let email: string | null = null;

    // A) normal: viene en email_addresses
    if (evt.data?.email_addresses?.length > 0) {
      email = evt.data.email_addresses[0].email_address;
    }

    // B) si está vacío: buscar primary ID
    if (!email && evt.data?.primary_email_address_id) {
      const primary = evt.data.email_addresses?.find(
        (x: any) => x.id === evt.data.primary_email_address_id
      );
      if (primary) email = primary.email_address;
    }

    // C) fallback
    if (!email && evt.data?.email_address) {
      email = evt.data.email_address;
    }

    if (!email) {
      console.error("❌ WEBHOOK sin email:", evt.data);
      return new Response("NO EMAIL", { status: 200 });
    }

    // ──────────────────────────────────────
    // Registrar usuario
    // ──────────────────────────────────────

    if (evt.type === "user.created") {
      await prisma.user.upsert({
        where: { email },
        update: {},
        create: {
          email,
          role: "PILOT",
        },
      });
    }

    return new Response("OK", { status: 200 });

  } catch (err) {
    console.error("❌ WEBHOOK ERROR:", err);
    return new Response("ERROR", { status: 400 });
  }
}







