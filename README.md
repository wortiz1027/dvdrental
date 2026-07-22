# 📀 DVD Rental Application - Especificación de Casos de Uso Estratégicos

## 🏗️ Diseño Bajo Arquitectura Hexagonal para Alta Concurrencia (Java 25 + Virtual Threads)

Este documento detalla los 5 casos de uso críticos identificados a partir del diagrama Entidad-Relación de la base de datos `dvdrental`. Cada flujo está diseñado para maximizar el uso de hilos virtuales (_Project Loom_), aislando por completo las reglas de negocio de los protocolos de transporte e infraestructura.

---

### 🎬 1. CreateRentalUseCase (Alquilar una Película)

<img src="https://unsplash.com" width="100%" alt="Cinema and Movie Production" />

- **Propósito**: Registrar de forma segura y transaccional el alquiler de una película por parte de un cliente.
- **Flujo de Negocio**:
  1.  **Validar** la existencia y el estado del cliente (`customer.activebool == true`).
  2.  **Verificar** la disponibilidad física de la copia en la tabla `inventory`. Una copia está disponible si no tiene registros activos en `rental` o si todos sus alquileres previos tienen una fecha de devolución (`return_date IS NOT NULL`).
  3.  **Insertar** de forma atómica el nuevo registro en la tabla `rental` asignando el empleado (`staff_id`) que atiende.
- **Tablas Involucradas**: `rental`, `inventory`, `customer`, `staff`.
- **Desafío Concurrente**: Evitar la doble reserva física (_Race Condition_). Se requiere implementar bloqueos pesimistas controlados (`SELECT ... FOR UPDATE`) sobre la fila de `inventory` para evitar que múltiples hilos virtuales alquilen la misma copia simultáneamente.

---

### 📦 2. ReturnRentalUseCase (Devolver una Película Alquilada)

<img src="https://unsplash.com" width="100%" alt="Returns and Logistics Counter" />

- **Propósito**: Procesar el retorno de una cinta de video, liberando inmediatamente su disponibilidad en el inventario global.
- **Flujo de Negocio**:
  1.  **Buscar** el registro activo en la tabla `rental` utilizando el identificador `rental_id`.
  2.  **Actualizar** la columna `return_date` con la marca de tiempo exacta del sistema operativo.
  3.  **Calcular** la diferencia de días transcurridos y compararla con el parámetro `rental_duration` (obtenido desde la relación con la tabla `film`) para determinar si existió un retraso en la entrega.
- **Tablas Involucradas**: `rental`, `inventory`, `film`.
- **Desafío Concurrente**: Escritura y actualización de alta velocidad en índices masivos de la base de datos Postgres sin degradar los tiempos de respuesta de la API.

---

### 💳 3. ProcessRentalPaymentUseCase (Registrar Pago de Alquiler)

<img src="https://unsplash.com" width="100%" alt="Financial Transaction and Payment" />

- **Propósito**: Asegurar el cobro monetario y mantener la consistencia contable del negocio vinculando el dinero a una renta específica.
- **Flujo de Negocio**:
  1.  **Validar** que el identificador `rental_id` asociado a la transacción exista y no posea pagos duplicados que saturen el sistema.
  2.  **Crear** e insertar de forma asíncrona un nuevo registro en la tabla `payment` asociando el monto exacto (`amount`), el cliente (`customer_id`) y el empleado de la sucursal (`staff_id`).
- **Tablas Involucradas**: `payment`, `rental`, `customer`, `staff`.
- **Desafío Concurrente**: Absorber ráfagas masivas de inserciones. Evaluará críticamente la configuración de procesamiento por lotes de la capa de persistencia (`hibernate.jdbc.batch_size: 50`) y la velocidad de reciclaje de conexiones del pool de HikariCP.

---

### 🔍 4. SearchAvailableFilmsUseCase (Buscar Películas Disponibles por Categoría) X

<img src="https://unsplash.com" width="100%" alt="Movie Shelves and Archive Catalog" />

- **Propósito**: Servir como pasarela de consulta masiva e interactiva para que los clientes naveguen por el catálogo digital.
- **Flujo de Negocio**:
  1.  **Filtrar** el catálogo de películas utilizando un identificador de género de la tabla `category`.
  2.  **Resolver** las relaciones mediante la tabla intermedia `film_category`.
  3.  **Cruzar** la información con las existencias para retornar únicamente los títulos que poseen stock físico real listo para renta.
- **Tablas Involucradas**: `film`, `film_category`, `category`, `inventory`, `rental`.
- **Desafío Concurrente**: Lecturas complejas de múltiples uniones (_JOINs_). Ideal para probar cómo Spring GraphQL resuelve subgrafos de datos en paralelo a través de hilos de Project Loom sin caer en el antipatrón de consultas SQL N+1.

---

### 📜 5. GetCustomerRentalHistoryUseCase (Consultar Historial del Cliente)

<img src="https://unsplash.com" width="100%" alt="Vintage Film and Retro Media" />

- **Propósito**: Exponer en los perfiles de los usuarios el listado cronológico de todas sus transacciones históricas.
- **Flujo de Negocio**:
  1.  **Consultar** de forma indexada todas las tuplas de la tabla `rental` cuyo atributo coincida con el `customer_id` suministrado.
  2.  **Resolver** los nombres de las películas consumiendo la relación con `inventory` y `film`.
  3.  **Estructurar** y ordenar la respuesta desde el alquiler más reciente hasta el más antiguo mediante paginación estricta de base de datos.
- **Tablas Involucradas**: `customer`, `rental`, `inventory`, `film`.
- **Desafío Concurrente**: Paginación intensiva y alta demanda de I/O de lectura simultánea bajo ráfagas concurrentes en HTTP/REST y protocolos binarios de alto rendimiento como gRPC.
