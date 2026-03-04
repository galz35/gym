import { Test, TestingModule } from '@nestjs/testing';
import { InventarioService } from './inventario.service';
import { DatabaseService } from '../../common/database/database.service';
import { BadRequestException } from '@nestjs/common';

describe('InventarioService', () => {
    let service: InventarioService;
    let dbService: any;

    beforeEach(async () => {
        const mockSql: any = jest.fn();
        mockSql.begin = jest.fn(async (callback) => await callback(mockSql));
        mockSql.json = jest.fn((val) => val);

        const mockDbService = {
            sql: mockSql,
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                InventarioService,
                { provide: DatabaseService, useValue: mockDbService },
            ],
        }).compile();

        service = module.get<InventarioService>(InventarioService);
        dbService = module.get<DatabaseService>(DatabaseService);
    });

    describe('registrarMerma', () => {
        const mockDto = {
            sucursalId: 'suc-1',
            productoId: 'prod-1',
            cantidad: 5,
            notas: 'Merma de prueba'
        };

        it('should throw BadRequestException if update fails (insufficient stock)', async () => {
            // Mock update to return nothing
            dbService.sql.mockResolvedValueOnce([]);

            await expect(service.registrarMerma('emp-1', 'user-1', mockDto))
                .rejects.toThrow(BadRequestException);
        });

        it('should register merma successfully', async () => {
            // 1. Update stock
            dbService.sql.mockResolvedValueOnce([{ id: 'inv-1' }]);
            // 2. Insert movement
            dbService.sql.mockResolvedValueOnce([{ id: 'mov-1' }]);

            const result = await service.registrarMerma('emp-1', 'user-1', mockDto);

            expect(result).toBeDefined();
            expect(result.id).toBe('mov-1');
            expect(dbService.sql).toHaveBeenCalled();
        });
    });

    describe('registrarEntrada', () => {
        const mockDto = {
            sucursalId: 'suc-1',
            productoId: 'prod-1',
            cantidad: 10,
            notas: 'Entrada de mercancia'
        };

        it('should register entry successfully', async () => {
            // 1. Upsert stock
            dbService.sql.mockResolvedValueOnce([{ id: 'inv-1' }]);
            // 2. Insert movement
            dbService.sql.mockResolvedValueOnce([{ id: 'mov-1' }]);

            const result = await service.registrarEntrada('emp-1', 'user-1', mockDto);

            expect(result).toBeDefined();
            expect(result.id).toBe('mov-1');
        });
    });
});
