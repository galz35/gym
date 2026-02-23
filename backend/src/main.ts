import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Habilitar CORS
  app.enableCors({
    origin: true, // Permitir reflect para desarrollo. Evita error de '*' con credentials: true
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
    allowedHeaders: 'Content-Type, Accept, Authorization, X-Sucursal-Id',
  });

  // Validaciones globales DTO
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
  }));

  app.useGlobalFilters(new AllExceptionsFilter());

  // Prefijo API (opcional pero recomendado)
  // app.setGlobalPrefix('api/v1');

  await app.listen(process.env.PORT || 3000);
  console.log(`Backend running on port ${process.env.PORT || 3000}`);
}
bootstrap();
