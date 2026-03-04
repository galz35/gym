import { Test, TestingModule } from '@nestjs/testing';
import { AsistenciaService } from './asistencia.service';
import { DatabaseService } from '../../common/database/database.service';
import { ForbiddenException, BadRequestException } from '@nestjs/common';

describe('AsistenciaService', () => {
  let service: AsistenciaService;
  let dbService: any;

  beforeEach(async () => {
    const mockSql: any = jest.fn();

    const mockDbService = {
      sql: mockSql,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AsistenciaService,
        { provide: DatabaseService, useValue: mockDbService },
      ],
    }).compile();

    service = module.get<AsistenciaService>(AsistenciaService);
    dbService = module.get<DatabaseService>(DatabaseService);
  });

  describe('validarAcceso', () => {
    const dto = { sucursalId: 'suc-1', clienteId: 'cli-1', notas: 'Test' };

    it('should throw ForbiddenException if stored procedure returns error', async () => {
      dbService.sql.mockResolvedValueOnce([
        { res: { error: 'MEMBRESIA_VENCIDA' } },
      ]);

      await expect(
        service.validarAcceso('emp-1', 'user-1', dto),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should return result if access is allowed', async () => {
      const mockRes = { permitido: true, mensaje: 'Bienvenido' };
      dbService.sql.mockResolvedValueOnce([{ res: mockRes }]);

      const result = await service.validarAcceso('emp-1', 'user-1', dto);
      expect(result).toEqual(mockRes);
    });
  });

  describe('registrarSalida', () => {
    it('should register exit successfully', async () => {
      dbService.sql.mockResolvedValueOnce([{ id: 'asist-1' }]);

      const result = await service.registrarSalida('cli-1', 'suc-1');
      expect(result.asistenciaId).toBe('asist-1');
      expect(result.mensaje).toContain('Salida registrada');
    });

    it('should throw BadRequestException if no active attendance found', async () => {
      dbService.sql.mockResolvedValueOnce([]);

      await expect(service.registrarSalida('cli-1', 'suc-1')).rejects.toThrow(
        BadRequestException,
      );
    });
  });
});
