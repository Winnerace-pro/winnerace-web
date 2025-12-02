export const dynamic = "force-dynamic";

import { Webhook } from "svix";
import { headers } from "next/headers";
import prisma from "@/lib/prisma";

export async function POST(req: Request) {
  try {
    const wh = new Webhook(process.env.CLERK_WEBHOOK_SECRET!);

    const rawBody = await req.text();
    const h = await headers();

    const headerPayload = {
      "svix-id": h.get("svix-id")!,
      "svix-signature": h.get("svix-signature")!,
      "svix-timestamp": h.get("svix-timestamp")!,
    };

    const event = wh.verify(rawBody, headerPayload) as any;

    if (event.type === "user.created") {
      const email = event.data.email_addresses[0].email_address;

      await prisma.user.create({
        data: {
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







