---
description: Hace commit en español de los cambios pendientes, sincroniza con el remoto y hace push
argument-hint: [contexto opcional para el mensaje]
disable-model-invocation: true
---

Haz commit y push de los cambios pendientes siguiendo estos pasos en orden:

1. **Revisa los cambios.** Ejecuta `git status` y `git diff` para entender qué cambió
   desde el último commit. Si no hay cambios, dímelo y detente.
   No incluyas archivos con secretos (`.env`, credenciales, llaves); si aparecen, avísame.

2. **Haz el commit en español.** Mensaje claro y específico:
   - Primera línea: resumen en imperativo de máximo 72 caracteres
     (ej. "Agrega validación de fechas en el servicio de afiliados").
   - Cuerpo opcional: qué cambió y por qué, en viñetas, solo si aporta.
   - Si los cambios no están relacionados entre sí, sepáralos en varios commits.
   Contexto adicional que te doy: $ARGUMENTS

3. **Sincroniza antes del push.** Ejecuta `git pull` en la rama actual.

4. **Si hay conflictos:**
   - Resuélvelos tú solo cuando la solución sea evidente (cambios en líneas distintas,
     imports, formato, ambos lados compatibles).
   - Detente y pregúntame, sin resolver nada, cuando el conflicto sea crítico:
     lógica de negocio donde ambos lados cambian el mismo comportamiento,
     migraciones o esquemas de base de datos, archivos de configuración o despliegue,
     código eliminado en un lado y modificado en el otro, o cualquier caso donde
     no estés seguro de cuál versión es la correcta.
     Muéstrame el archivo, las dos versiones y tu recomendación.

5. **Verifica y haz push.** Si resolviste conflictos, ejecuta las pruebas del proyecto
   antes del push. Luego `git push`. Nunca uses `--force`.

6. **Resume lo hecho:** commits creados, conflictos resueltos (archivo y cómo) y
   resultado del push.
