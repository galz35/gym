import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { DatabaseService } from '../../common/database/database.service';
import * as bcrypt from 'bcrypt';
import { UnauthorizedException, ForbiddenException } from '@nestjs/common';

jest.mock('bcrypt');

describe('AuthService', () => {
  let service: AuthService;
  let dbService: any;
  let jwtService: JwtService;

  beforeEach(async () => {
    const mockSql: any = jest.fn();

    const mockDbService = {
      sql: mockSql,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: DatabaseService, useValue: mockDbService },
        {
          provide: JwtService,
          useValue: {
            signAsync: jest.fn().mockResolvedValue('test-token'),
            verifyAsync: jest
              .fn()
              .mockResolvedValue({ sub: 'user-1', tokenVersion: 1 }),
          },
        },
        {
          provide: ConfigService,
          useValue: { get: jest.fn().mockReturnValue('secret') },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    dbService = module.get<DatabaseService>(DatabaseService);
    jwtService = module.get<JwtService>(JwtService);
  });

  describe('validateUser', () => {
    it('should return user info without hash if password matches', async () => {
      const mockUser = {
        id: 'user-1',
        email: 'test@gym.com',
        hash: 'hashed',
        estado: 'ACTIVO',
      };
      dbService.sql.mockResolvedValueOnce([mockUser]);
      (bcrypt.compare as jest.Mock).mockResolvedValueOnce(true);

      const result = await service.validateUser('test@gym.com', 'password');
      expect(result.email).toBe('test@gym.com');
      expect(result.hash).toBeUndefined();
    });

    it('should return null if password does not match', async () => {
      dbService.sql.mockResolvedValueOnce([
        { hash: 'hashed', estado: 'ACTIVO' },
      ]);
      (bcrypt.compare as jest.Mock).mockResolvedValueOnce(false);

      const result = await service.validateUser('test@gym.com', 'wrong');
      expect(result).toBeNull();
    });
  });

  describe('login', () => {
    it('should throw UnauthorizedException if user not found', async () => {
      dbService.sql.mockResolvedValueOnce([]); // No user

      await expect(
        service.login({ email: 'x@x.com', password: 'p' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should return tokens and user info on success', async () => {
      const mockUser = {
        id: 'user-1',
        email: 'x@x.com',
        hash: 'h',
        estado: 'ACTIVO',
        token_version: 1,
      };
      dbService.sql.mockResolvedValueOnce([mockUser]);
      (bcrypt.compare as jest.Mock).mockResolvedValueOnce(true);
      dbService.sql.mockResolvedValueOnce([]); // Update login time

      const result = await service.login({ email: 'x@x.com', password: 'p' });
      expect(result.accessToken).toBeDefined();
      expect(result.user.id).toBe('user-1');
    });
  });

  describe('refresh', () => {
    it('should throw ForbiddenException if token version mismatch', async () => {
      // Mock verifyAsync already returns version 1
      dbService.sql.mockResolvedValueOnce([
        { id: 'user-1', token_version: 2, estado: 'ACTIVO' },
      ]);

      await expect(
        service.refresh({ refreshToken: 'expired' }),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
