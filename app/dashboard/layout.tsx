import { auth } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { userId } = await auth(); // ✔️ Versión correcta de Clerk 2025

  if (!userId) {
    redirect("/sign-in");
  }

  return <>{children}</>;
}





