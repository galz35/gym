import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class SucursalMiddleware implements NestMiddleware {
    use(req: any, res: Response, next: NextFunction) {
        const sucursalId = req.headers['x-sucursal-id'] || req.query['sucursalId'] || (req.body && req.body['sucursalId']);

        if (sucursalId) {
            // Store on request object for later use
            req['_sucursalId'] = sucursalId;

            // If req.user already exists (unlikely at middleware stage, but safe)
            if (req.user) {
                req.user.sucursalId = sucursalId;
            }

            // Override the req.user setter to inject sucursalId when AuthGuard sets it
            const originalUser = req.user;
            Object.defineProperty(req, 'user', {
                get: function () { return this._user; },
                set: function (val) {
                    if (val && this._sucursalId) {
                        val.sucursalId = this._sucursalId;
                    }
                    this._user = val;
                },
                configurable: true,
                enumerable: true,
            });
            // Re-set if already existed
            if (originalUser) {
                req.user = originalUser;
            }
        }

        next();
    }
}
