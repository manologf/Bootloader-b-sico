# Bootloader en Ensamblador

## Descripción
Este proyecto implementa un bootloader en ensamblador x86, el cual actúa como un mini-sistema interactivo que permite ejecutar comandos básicos. El código se carga en la dirección de memoria 0x7C00 y proporciona funcionalidades como mostrar la hora y la fecha del sistema, limpiar la pantalla y mostrar información del sistema.

## Características
- **Interfaz de línea de comandos (CLI)** con un prompt interactivo.
- **Soporte para los siguientes comandos:**
  - `INFO`: Muestra información del sistema.
  - `TIME`: Muestra la hora actual del sistema.
  - `DATE`: Muestra la fecha actual del sistema.
  - `CLR`: Limpia la pantalla.
  - `EXIT`: Sale del programa y detiene la ejecución.
  - `HELP`: Muestra los comandos disponibles.
- **Lectura de entrada del usuario** con soporte para borrar caracteres.
- **Comparación de cadenas** para interpretar comandos.
- **Uso de interrupciones BIOS** para obtener información del sistema.

## Requisitos
Para ensamblar y ejecutar este bootloader, se necesitan las siguientes herramientas:
- [NASM](https://www.nasm.us/) (Netwide Assembler) para compilar el código ensamblador.
- [QEMU](https://www.qemu.org/) para emular el código sin necesidad de hardware real.

## Instalación y Uso
### Ensamblado del Bootloader
Para ensamblar el código, ejecuta el siguiente comando en la terminal:
```sh
nasm -f bin bootloader.asm -o bootloader.img
```

### Ejecución en QEMU
Si deseas probar el bootloader en QEMU, usa el siguiente comando:
```sh
qemu-system-x86_64 -drive format=raw,file=bootloader.img,index=0,if=floppy
```
O puedes utilizar el script de ejecución incluido:
```sh
./ejecutar.sh  # En Linux
```

## Estructura del Código
El código fuente se organiza de la siguiente manera:
- **Prompt interactivo**: Muestra `Mini-Shell> ` y espera comandos del usuario.
- **Captura de entrada**: Usa la interrupción `INT 16h` para leer caracteres.
- **Procesamiento de comandos**: Se comparan las entradas con cadenas predefinidas.
- **Impresión de datos**: Se usa `INT 10h` para mostrar información en pantalla.
- **Manejo de la fecha y hora**: Se usan `INT 1Ah` y conversiones ASCII para mostrar la información correctamente.

## Contribuciones
Si deseas mejorar este bootloader, puedes clonar el repositorio y hacer una `pull request` con mejoras o nuevas funcionalidades.

## Licencia
Este proyecto es de código abierto y puede ser modificado libremente.


