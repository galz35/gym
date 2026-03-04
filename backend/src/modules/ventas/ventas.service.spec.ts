import { Test, TestingModule } from '@nestjs/testing';
import { VentasService } from './ventas.service';
import { DatabaseService } from '../../common/database/database.service';
import { BadRequestException, ConflictException } from '@nestjs/common';

describe('VentasService', () => {
  let service: VentasService;
  let dbService: any;

  beforeEach(async () => {
    const mockSql: any = jest.fn();
    mockSql.begin = jest.fn(async (callback) => await callback(mockSql));

    const mockDbService = {
      sql: mockSql,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        VentasService,
        { provide: DatabaseService, useValue: mockDbService },
      ],
    }).compile();

    service = module.get<VentasService>(VentasService);
    dbService = module.get<DatabaseService>(DatabaseService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createVenta', () => {
    const mockPayload = {
      cajaId: 'caja-1',
      clienteId: 'cliente-1',
      totalCentavos: 1000,
      detalles: [
        { productoId: 'prod-1', cantidad: 2, precioUnit: 500, subtotal: 1000 },
      ],
      pagos: [{ monto: 1000, metodo: 'EFECTIVO' }],
    };

    it('should throw BadRequestException if totalCentavos is negative', async () => {
      await expect(
        service.createVenta('emp-1', 'suc-1', 'user-1', {
          ...mockPayload,
          totalCentavos: -1,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if caja is not open', async () => {
      // Mock caja check
      dbService.sql.mockResolvedValueOnce([{ estado: 'CERRADA' }]);

      await expect(
        service.createVenta('emp-1', 'suc-1', 'user-1', mockPayload),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw ConflictException if stock is insufficient', async () => {
      // 1. Caja check
      dbService.sql.mockResolvedValueOnce([{ estado: 'ABIERTA' }]);
      // 2. Insert venta (auto-mocked via jest.fn())
      dbService.sql.mockResolvedValueOnce([{ id: 'venta-1' }]);
      // 3. Update stock (mock null/empty to simulate failure)
      dbService.sql.mockResolvedValueOnce([]);

      await expect(
        service.createVenta('emp-1', 'suc-1', 'user-1', mockPayload),
      ).rejects.toThrow(ConflictException);
    });

    it('should create a sale successfully', async () => {
      // 1. Caja check
      dbService.sql.mockResolvedValueOnce([{ estado: 'ABIERTA' }]);
      // 2. Insert venta
      dbService.sql.mockResolvedValueOnce([{ id: 'venta-1' }]);
      // 3. Update stock
      dbService.sql.mockResolvedValueOnce([{ id: 'inv-1' }]);
      // 4. Insert det (void)
      dbService.sql.mockResolvedValueOnce([]);
      // 5. Insert mov (void)
      dbService.sql.mockResolvedValueOnce([]);
      // 6. Insert pago (void)
      dbService.sql.mockResolvedValueOnce([]);

      const result = await service.createVenta(
        'emp-1',
        'suc-1',
        'user-1',
        mockPayload,
      );

      expect(result).toBeDefined();
      expect(result.id).toBe('venta-1');
      expect(dbService.sql).toHaveBeenCalled();
    });
  });
});
