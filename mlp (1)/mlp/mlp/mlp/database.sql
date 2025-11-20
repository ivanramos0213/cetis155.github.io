-- =====================================================
-- CETIS 155 CLASSROOM - BASE DE DATOS
-- Plataforma Educativa tipo Google Classroom
-- =====================================================

DROP DATABASE IF EXISTS medi_db;
CREATE DATABASE medi_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medi_db;

-- =====================================================
-- TABLA: usuarios
-- Almacena alumnos, profesores y administradores
-- =====================================================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    rol ENUM('admin', 'profesor', 'alumno') NOT NULL DEFAULT 'alumno',
    nombre_completo VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usuario (usuario),
    INDEX idx_correo (correo),
    INDEX idx_rol (rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: clases
-- Información de cada clase (materia)
-- =====================================================
CREATE TABLE clases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    profesor_id INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (profesor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_codigo (codigo),
    INDEX idx_profesor (profesor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: alumnos_clases
-- Relación muchos a muchos entre alumnos y clases
-- =====================================================
CREATE TABLE alumnos_clases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    alumno_id INT NOT NULL,
    clase_id INT NOT NULL,
    fecha_inscripcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (alumno_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (clase_id) REFERENCES clases(id) ON DELETE CASCADE,
    UNIQUE KEY unique_alumno_clase (alumno_id, clase_id),
    INDEX idx_alumno (alumno_id),
    INDEX idx_clase (clase_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: tareas
-- Tareas asignadas por profesores
-- =====================================================
CREATE TABLE tareas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clase_id INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega DATETIME,
    puntos INT DEFAULT 100,
    FOREIGN KEY (clase_id) REFERENCES clases(id) ON DELETE CASCADE,
    INDEX idx_clase (clase_id),
    INDEX idx_fecha_entrega (fecha_entrega)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: entregas
-- Entregas de tareas por alumnos
-- =====================================================
CREATE TABLE entregas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarea_id INT NOT NULL,
    alumno_id INT NOT NULL,
    contenido TEXT,
    archivo_url VARCHAR(255),
    fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    calificacion DECIMAL(5,2),
    comentarios TEXT,
    FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    FOREIGN KEY (alumno_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE KEY unique_entrega (tarea_id, alumno_id),
    INDEX idx_tarea (tarea_id),
    INDEX idx_alumno (alumno_id),
    INDEX idx_fecha (fecha_entrega)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- DATOS INICIALES
-- =====================================================

-- Usuario Administrador
-- Contraseña: admin
INSERT INTO usuarios (usuario, password, correo, telefono, rol, nombre_completo) VALUES
('admin', 'admin', 'admin@cetis155.edu.mx', '0000000000', 'admin', 'Administrador CETIS 155');

-- Profesores de ejemplo
-- Contraseña para todos: 123
INSERT INTO usuarios (usuario, password, correo, telefono, rol, nombre_completo) VALUES
('prof_matematicas', '123', 'matematicas@cetis155.edu.mx', '5551234567', 'profesor', 'Juan Pérez García'),
('prof_fisica', '123', 'fisica@cetis155.edu.mx', '5551234568', 'profesor', 'María López Rodríguez'),
('prof_programacion', '123', 'programacion@cetis155.edu.mx', '5551234569', 'profesor', 'Carlos Ramírez Torres'),
('prof_ingles', '123', 'ingles@cetis155.edu.mx', '5551234570', 'profesor', 'Ana Martínez Cruz');

-- Alumnos de ejemplo
-- Contraseña para todos: 123
INSERT INTO usuarios (usuario, password, correo, telefono, rol, nombre_completo) VALUES
('alumno01', '123', 'alumno01@cetis155.edu.mx', '5559876543', 'alumno', 'Carlos Hernández Sánchez'),
('alumno02', '123', 'alumno02@cetis155.edu.mx', '5559876544', 'alumno', 'Ana Martínez González'),
('alumno03', '123', 'alumno03@cetis155.edu.mx', '5559876545', 'alumno', 'Luis García Fernández'),
('alumno04', '123', 'alumno04@cetis155.edu.mx', '5559876546', 'alumno', 'Sofia Rodríguez Morales'),
('alumno05', '123', 'alumno05@cetis155.edu.mx', '5559876547', 'alumno', 'Diego López Ramírez');

-- Clases de ejemplo
INSERT INTO clases (nombre, descripcion, codigo, profesor_id) VALUES
('Matemáticas Avanzadas', 'Cálculo diferencial e integral', 'MAT2024', 2),
('Física Cuántica', 'Introducción a la física cuántica', 'FIS2024', 3),
('Programación Python', 'Fundamentos de programación en Python', 'PYT2024', 4),
('Inglés Intermedio', 'Conversación y gramática nivel B1', 'ENG2024', 5),
('Algebra Lineal', 'Vectores, matrices y transformaciones', 'ALG2024', 2),
('Química Orgánica', 'Compuestos orgánicos y reacciones', 'QUI2024', 3);

-- Inscribir alumnos en clases
INSERT INTO alumnos_clases (alumno_id, clase_id) VALUES
-- Carlos (alumno01) en 3 clases
(6, 1), (6, 2), (6, 3),
-- Ana (alumno02) en 3 clases
(7, 1), (7, 2), (7, 4),
-- Luis (alumno03) en 4 clases
(8, 1), (8, 3), (8, 4), (8, 5),
-- Sofia (alumno04) en 3 clases
(9, 2), (9, 3), (9, 6),
-- Diego (alumno05) en 3 clases
(10, 1), (10, 4), (10, 5);

-- Tareas de ejemplo
INSERT INTO tareas (clase_id, titulo, descripcion, fecha_entrega, puntos) VALUES
-- Matemáticas
(1, 'Derivadas parciales', 'Resolver los ejercicios del capítulo 5 del libro de texto. Mostrar todo el procedimiento.', '2025-12-15 23:59:00', 100),
(1, 'Integrales múltiples', 'Problemas de aplicación de integrales dobles. Resolver ejercicios 1 al 10.', '2025-12-20 23:59:00', 100),
(1, 'Examen parcial preparación', 'Estudiar temas 1 al 4 y resolver la guía de estudio proporcionada.', '2025-12-10 23:59:00', 50),

-- Física
(2, 'Experimento de doble rendija', 'Reporte del experimento realizado en laboratorio. Incluir análisis y conclusiones.', '2025-12-18 23:59:00', 100),
(2, 'Ecuación de Schrödinger', 'Resolver problemas propuestos y explicar el significado físico de cada término.', '2025-12-22 23:59:00', 100),

-- Programación
(3, 'Proyecto: Calculadora', 'Crear una calculadora en Python con operaciones básicas y avanzadas.', '2025-12-25 23:59:00', 150),
(3, 'Estructuras de datos', 'Implementar listas, pilas y colas en Python. Documentar cada función.', '2025-12-16 23:59:00', 100),

-- Inglés
(4, 'Essay: My Future Goals', 'Write a 300-word essay about your future goals and aspirations.', '2025-12-17 23:59:00', 100),
(4, 'Oral Presentation', 'Prepare a 5-minute presentation about a topic of your choice.', '2025-12-23 23:59:00', 100),

-- Algebra
(5, 'Sistemas de ecuaciones', 'Resolver sistemas de ecuaciones lineales usando métodos matriciales.', '2025-12-14 23:59:00', 100),

-- Química
(6, 'Reacciones orgánicas', 'Identificar y nombrar compuestos orgánicos de la lista proporcionada.', '2025-12-19 23:59:00', 100);

-- Entregas de ejemplo
INSERT INTO entregas (tarea_id, alumno_id, contenido, calificacion, comentarios) VALUES
-- Carlos ha entregado algunas tareas
(1, 6, 'Resolví todos los ejercicios del capítulo 5. Adjunto mis procedimientos:\n\n1. Para la primera derivada parcial...\n2. En el segundo ejercicio...\n\nConclusiones: Las derivadas parciales son útiles para...', 95.5, 'Excelente trabajo. Solo un pequeño error en el ejercicio 3.'),
(4, 6, 'Reporte del Experimento de Doble Rendija\n\nObjetivo: Demostrar la naturaleza ondulatoria de la luz.\n\nMateriales utilizados:\n- Láser\n- Rejilla de difracción\n- Pantalla\n\nProcedimiento:\n1. Configuramos el láser...\n2. Colocamos la rejilla...\n\nResultados: Se observó el patrón de interferencia esperado...\n\nConclusiones: Este experimento confirma...', 98.0, 'Excelente reporte, muy completo y bien documentado.'),

-- Ana ha entregado tareas
(1, 7, 'Ejercicios resueltos del capítulo 5:\n\nEjercicio 1: f(x,y) = x²y³\nDerivada parcial respecto a x: 2xy³\nDerivada parcial respecto a y: 3x²y²\n\nEjercicio 2: ...\n', 88.0, 'Buen trabajo, pero revisa el ejercicio 7.'),
(8, 7, 'Essay: My Future Goals\n\nMy name is Ana and I want to talk about my future goals. First, I want to finish my studies at CETIS 155 with excellent grades. After that, I plan to study engineering at the university.\n\nMy main goal is to become a software engineer because I love programming and technology. I believe that technology can change the world and make it better...\n\n[300 words total]', 92.0, 'Very good essay! Your ideas are clear and well organized.'),

-- Luis ha entregado tareas
(3, 8, 'Guía de estudio resuelta:\n\nTema 1: Límites\n- Definición formal de límite\n- Propiedades de los límites\n- Ejercicios resueltos...\n\nTema 2: Continuidad\n- Definición de continuidad\n- Tipos de discontinuidades...\n\n[Continúa con todos los temas]', NULL, NULL),
(7, 8, 'Proyecto: Calculadora en Python\n\n```python\ndef suma(a, b):\n    return a + b\n\ndef resta(a, b):\n    return a - b\n\ndef multiplicacion(a, b):\n    return a * b\n\ndef division(a, b):\n    if b == 0:\n        return "Error: División por cero"\n    return a / b\n\n# Funciones avanzadas\nimport math\n\ndef raiz_cuadrada(a):\n    return math.sqrt(a)\n\ndef potencia(a, b):\n    return a ** b\n\n# Menú principal\nwhile True:\n    print("Calculadora")\n    print("1. Suma")\n    # ... más opciones\n```\n\nLa calculadora incluye todas las operaciones solicitadas.', NULL, NULL);

-- =====================================================
-- VISTAS ÚTILES
-- =====================================================

-- Vista de estadísticas de clases
CREATE OR REPLACE VIEW vista_estadisticas_clases AS
SELECT
    c.id,
    c.nombre,
    c.codigo,
    u.nombre_completo AS profesor,
    COUNT(DISTINCT ac.alumno_id) AS total_alumnos,
    COUNT(DISTINCT t.id) AS total_tareas
FROM clases c
JOIN usuarios u ON c.profesor_id = u.id
LEFT JOIN alumnos_clases ac ON c.id = ac.clase_id
LEFT JOIN tareas t ON c.id = t.clase_id
GROUP BY c.id, c.nombre, c.codigo, u.nombre_completo;

-- Vista de progreso de alumnos
CREATE OR REPLACE VIEW vista_progreso_alumnos AS
SELECT
    u.id AS alumno_id,
    u.nombre_completo AS alumno,
    c.id AS clase_id,
    c.nombre AS clase,
    COUNT(DISTINCT t.id) AS tareas_totales,
    COUNT(DISTINCT e.id) AS tareas_entregadas,
    AVG(e.calificacion) AS promedio
FROM usuarios u
JOIN alumnos_clases ac ON u.id = ac.alumno_id
JOIN clases c ON ac.clase_id = c.id
LEFT JOIN tareas t ON c.id = t.clase_id
LEFT JOIN entregas e ON t.id = e.tarea_id AND u.id = e.alumno_id
WHERE u.rol = 'alumno'
GROUP BY u.id, u.nombre_completo, c.id, c.nombre;

-- Vista de tareas pendientes
CREATE OR REPLACE VIEW vista_tareas_pendientes AS
SELECT
    u.id AS alumno_id,
    u.nombre_completo AS alumno,
    t.id AS tarea_id,
    t.titulo AS tarea,
    c.nombre AS clase,
    t.fecha_entrega,
    t.puntos,
    CASE
        WHEN e.id IS NULL THEN 'No entregada'
        WHEN e.calificacion IS NULL THEN 'Entregada sin calificar'
        ELSE 'Calificada'
    END AS estado
FROM usuarios u
JOIN alumnos_clases ac ON u.id = ac.alumno_id
JOIN clases c ON ac.clase_id = c.id
JOIN tareas t ON c.id = t.clase_id
LEFT JOIN entregas e ON t.id = e.tarea_id AND u.id = e.alumno_id
WHERE u.rol = 'alumno'
ORDER BY t.fecha_entrega ASC;

-- =====================================================
-- PROCEDIMIENTOS ALMACENADOS
-- =====================================================

DELIMITER //

-- Obtener todas las clases de un alumno
CREATE PROCEDURE obtener_clases_alumno(IN p_alumno_id INT)
BEGIN
    SELECT
        c.id,
        c.nombre,
        c.descripcion,
        c.codigo,
        u.nombre_completo AS profesor
    FROM clases c
    JOIN alumnos_clases ac ON c.id = ac.clase_id
    JOIN usuarios u ON c.profesor_id = u.id
    WHERE ac.alumno_id = p_alumno_id
    ORDER BY c.nombre;
END //

-- Obtener tareas pendientes de un alumno
CREATE PROCEDURE obtener_tareas_pendientes(IN p_alumno_id INT)
BEGIN
    SELECT
        t.id,
        t.titulo,
        t.descripcion,
        t.fecha_entrega,
        t.puntos,
        c.nombre AS clase
    FROM tareas t
    JOIN clases c ON t.clase_id = c.id
    JOIN alumnos_clases ac ON c.id = ac.clase_id
    LEFT JOIN entregas e ON t.id = e.tarea_id AND e.alumno_id = p_alumno_id
    WHERE ac.alumno_id = p_alumno_id
    AND e.id IS NULL
    ORDER BY t.fecha_entrega ASC;
END //

-- Calcular promedio de un alumno en una clase
CREATE PROCEDURE calcular_promedio_clase(
    IN p_alumno_id INT,
    IN p_clase_id INT,
    OUT p_promedio DECIMAL(5,2)
)
BEGIN
    SELECT AVG(e.calificacion)
    INTO p_promedio
    FROM entregas e
    JOIN tareas t ON e.tarea_id = t.id
    WHERE e.alumno_id = p_alumno_id
    AND t.clase_id = p_clase_id
    AND e.calificacion IS NOT NULL;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Validar que la calificación esté en el rango correcto
CREATE TRIGGER before_entrega_update
BEFORE UPDATE ON entregas
FOR EACH ROW
BEGIN
    DECLARE max_puntos INT;

    IF NEW.calificacion IS NOT NULL THEN
        SELECT puntos INTO max_puntos
        FROM tareas
        WHERE id = NEW.tarea_id;

        IF NEW.calificacion < 0 OR NEW.calificacion > max_puntos THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La calificación debe estar entre 0 y los puntos máximos de la tarea';
        END IF;
    END IF;
END //

-- Evitar inscripción duplicada
CREATE TRIGGER before_alumno_clase_insert
BEFORE INSERT ON alumnos_clases
FOR EACH ROW
BEGIN
    DECLARE alumno_rol VARCHAR(20);

    SELECT rol INTO alumno_rol
    FROM usuarios
    WHERE id = NEW.alumno_id;

    IF alumno_rol != 'alumno' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo los usuarios con rol alumno pueden inscribirse en clases';
    END IF;
END //

DELIMITER ;

-- =====================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =====================================================

CREATE INDEX idx_tareas_fecha_clase ON tareas(clase_id, fecha_entrega);
CREATE INDEX idx_entregas_calificacion ON entregas(calificacion);
CREATE INDEX idx_alumnos_clases_fecha ON alumnos_clases(fecha_inscripcion);

-- =====================================================
-- CONSULTAS DE VERIFICACIÓN
-- =====================================================

SELECT '========================================' AS '';
SELECT 'BASE DE DATOS CREADA EXITOSAMENTE' AS '';
SELECT '========================================' AS '';
SELECT '' AS '';

SELECT 'RESUMEN DE DATOS:' AS '';
SELECT COUNT(*) AS Total_Usuarios FROM usuarios;
SELECT COUNT(*) AS Total_Clases FROM clases;
SELECT COUNT(*) AS Total_Tareas FROM tareas;
SELECT COUNT(*) AS Total_Entregas FROM entregas;
SELECT COUNT(*) AS Total_Inscripciones FROM alumnos_clases;

SELECT '' AS '';
SELECT 'CREDENCIALES DE ACCESO:' AS '';
SELECT '- Admin: usuario=admin, password=admin' AS '';
SELECT '- Profesores: prof_matematicas/prof_fisica/etc, password=123' AS '';
SELECT '- Alumnos: alumno01/alumno02/etc, password=123' AS '';

SELECT '' AS '';
SELECT 'NOTA: Las contraseñas están en texto plano para facilitar el desarrollo.' AS '';

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================
