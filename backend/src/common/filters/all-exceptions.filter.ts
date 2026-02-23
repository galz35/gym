import {
    ExceptionFilter,
    Catch,
    ArgumentsHost,
    HttpException,
    HttpStatus,
    Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
    private readonly logger = new Logger('AllExceptionsFilter');

    catch(exception: unknown, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const request = ctx.getRequest<Request>();

        const status =
            exception instanceof HttpException
                ? exception.getStatus()
                : HttpStatus.INTERNAL_SERVER_ERROR;

        const message =
            exception instanceof HttpException
                ? exception.getResponse()
                : { message: (exception as Error).message || 'Internal server error' };

        // Extraemos detalles del error para el log
        const errorDetails = {
            statusCode: status,
            timestamp: new Date().toISOString(),
            path: request.url,
            method: request.method,
            body: request.body,
            params: request.params,
            query: request.query,
            user: (request as any).user?.userId || 'anonymous',
            exception: exception instanceof Error ? {
                message: exception.message,
                stack: exception.stack?.split('\n').slice(0, 5) // Guardamos solo el inicio del stack para no saturar
            } : exception,
        };

        // Logeamos el error con un formato fácil de leer en Render/Consola
        this.logger.error(
            `HTTP Error ${status} on ${request.method} ${request.url} from ${errorDetails.user}`,
            JSON.stringify(errorDetails, null, 2),
        );

        response.status(status).json({
            ...(typeof message === 'object' ? message : { message }),
            timestamp: new Date().toISOString(),
            path: request.url,
        });
    }
}
