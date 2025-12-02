import bcrypt from 'bcrypt';

/**
 * Hashea una contraseña en texto plano usando bcrypt.
 */
export async function hashPassword(plainPassword: string): Promise<string> {
  const saltRounds = 10;
  return bcrypt.hash(plainPassword, saltRounds);
}
