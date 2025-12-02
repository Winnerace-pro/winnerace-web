-- AlterTable
ALTER TABLE "public"."User" ADD COLUMN     "country" TEXT,
ADD COLUMN     "displayName" TEXT NOT NULL DEFAULT '';
