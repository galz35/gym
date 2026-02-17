import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class SucursalMiddleware implements NestMiddleware {
    use(req: any, res: Response, next: NextFunction) {
        const sucursalId = req.headers['x-sucursal-id'] || req.query['sucursalId'] || (req.body && req.body['sucursalId']);

        if (sucursalId && req.user) {
            req.user.sucursalId = sucursalId;
        } else if (sucursalId) {
            // If req.user doesn't exist yet (before AuthGuard), 
            // we can still attach it to req for later use
            req['sucursalId'] = sucursalId;
        }

        next();
    }
}
