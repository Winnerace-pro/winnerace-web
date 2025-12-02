/*
  Warnings:

  - Added the required column `password` to the `User` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "public"."UserRole" AS ENUM ('PILOT', 'MANAGER', 'ADMIN');

-- CreateEnum
CREATE TYPE "public"."TeamRole" AS ENUM ('TITULAR', 'ACADEMIA', 'MANAGER');

-- CreateEnum
CREATE TYPE "public"."OfferStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED');

-- AlterTable
ALTER TABLE "public"."User" ADD COLUMN     "password" TEXT NOT NULL,
ADD COLUMN     "role" "public"."UserRole" NOT NULL DEFAULT 'PILOT';

-- CreateTable
CREATE TABLE "public"."Pilot" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "avatarUrl" TEXT,
    "iracingId" INTEGER,
    "iratingOval" INTEGER DEFAULT 0,
    "iratingRoad" INTEGER DEFAULT 0,
    "iratingFormula" INTEGER DEFAULT 0,
    "srOval" DOUBLE PRECISION DEFAULT 0,
    "srRoad" DOUBLE PRECISION DEFAULT 0,
    "srFormula" DOUBLE PRECISION DEFAULT 0,
    "wrPointsTotal" INTEGER NOT NULL DEFAULT 0,
    "wrPointsSplit" INTEGER NOT NULL DEFAULT 0,
    "marketValue" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Pilot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Team" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "logoUrl" TEXT,
    "managerId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Team_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."TeamMembership" (
    "id" SERIAL NOT NULL,
    "teamId" INTEGER NOT NULL,
    "pilotId" INTEGER NOT NULL,
    "role" "public"."TeamRole" NOT NULL,
    "contractEnd" TIMESTAMP(3),
    "clause" INTEGER,

    CONSTRAINT "TeamMembership_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Season" (
    "id" SERIAL NOT NULL,
    "year" INTEGER NOT NULL,

    CONSTRAINT "Season_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Split" (
    "id" SERIAL NOT NULL,
    "seasonId" INTEGER NOT NULL,
    "index" INTEGER NOT NULL,

    CONSTRAINT "Split_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."RaceResult" (
    "id" SERIAL NOT NULL,
    "pilotId" INTEGER NOT NULL,
    "splitId" INTEGER NOT NULL,
    "irChange" INTEGER NOT NULL,
    "sof" INTEGER NOT NULL,
    "pointsWR" INTEGER NOT NULL,
    "incidents" INTEGER NOT NULL,
    "hasPole" BOOLEAN NOT NULL DEFAULT false,
    "hasFastLap" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RaceResult_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."TransferOffer" (
    "id" SERIAL NOT NULL,
    "teamFromId" INTEGER,
    "teamToId" INTEGER NOT NULL,
    "pilotId" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "status" "public"."OfferStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TransferOffer_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Pilot_userId_key" ON "public"."Pilot"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Team_name_key" ON "public"."Team"("name");

-- AddForeignKey
ALTER TABLE "public"."Pilot" ADD CONSTRAINT "Pilot_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Team" ADD CONSTRAINT "Team_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TeamMembership" ADD CONSTRAINT "TeamMembership_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "public"."Team"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TeamMembership" ADD CONSTRAINT "TeamMembership_pilotId_fkey" FOREIGN KEY ("pilotId") REFERENCES "public"."Pilot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Split" ADD CONSTRAINT "Split_seasonId_fkey" FOREIGN KEY ("seasonId") REFERENCES "public"."Season"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."RaceResult" ADD CONSTRAINT "RaceResult_pilotId_fkey" FOREIGN KEY ("pilotId") REFERENCES "public"."Pilot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."RaceResult" ADD CONSTRAINT "RaceResult_splitId_fkey" FOREIGN KEY ("splitId") REFERENCES "public"."Split"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TransferOffer" ADD CONSTRAINT "TransferOffer_pilotId_fkey" FOREIGN KEY ("pilotId") REFERENCES "public"."Pilot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TransferOffer" ADD CONSTRAINT "TransferOffer_teamToId_fkey" FOREIGN KEY ("teamToId") REFERENCES "public"."Team"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TransferOffer" ADD CONSTRAINT "TransferOffer_teamFromId_fkey" FOREIGN KEY ("teamFromId") REFERENCES "public"."Team"("id") ON DELETE SET NULL ON UPDATE CASCADE;
