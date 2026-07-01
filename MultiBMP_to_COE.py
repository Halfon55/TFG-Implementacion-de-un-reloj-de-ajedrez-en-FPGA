from PIL import Image
import os
import math


def multi_bmp_to_coe_segmented(image_paths, coe_path, max_depth=1048576):
    try:
        images = []
        for path in image_paths:
            img = Image.open(path).convert('1')
            images.append(img)

        width, height = images[0].size
        total_pixels = width * height

        # Calculamos cuántos segmentos necesitamos
        num_segments = math.ceil(total_pixels / max_depth)

        # DETERMINAMOS LA PROFUNDIDAD REAL:
        # Si la imagen es menor al máximo, usamos total_pixels.
        # Si es mayor, la cortamos en max_depth (los píxeles extra irán a lo ancho).
        actual_depth = min(total_pixels, max_depth)

        print(f"Total píxeles: {total_pixels}")
        print(f"Segmentos necesarios: {num_segments}")
        print(f"Profundidad final del COE: {actual_depth}")

        with open(coe_path, 'w') as f:
            f.write("memory_initialization_radix = 2;\n")
            f.write("memory_initialization_vector =\n")

            # 1. Extraemos todos los bits de todas las imágenes
            all_bits = []
            for y in range(height):
                for x in range(width):
                    pixel_bits = ""
                    for img in images:
                        pixel = img.getpixel((x, y))
                        bit = "1" if pixel == 0 else "0"  # Negro = 1, Blanco = 0
                        pixel_bits += bit
                    all_bits.append(pixel_bits)

            # 2. Escribimos en el COE usando actual_depth como límite
            for i in range(actual_depth):
                full_word = ""
                # Concatenamos los segmentos de izquierda a derecha (S_n ... S_1 S_0)
                for s in range(num_segments - 1, -1, -1):
                    index = i + (s * max_depth)
                    if index < total_pixels:
                        full_word += all_bits[index]
                    else:
                        # Relleno con ceros para completar el ancho de palabra si el segmento está vacío
                        full_word += "0" * len(image_paths)

                # Formateo de fin de línea o fin de fichero
                if i == actual_depth - 1:
                    f.write(f"{full_word};")
                else:
                    f.write(f"{full_word},\n")

        print(f"Éxito: {coe_path} creado.")
        print(f"Nueva profundidad: {actual_depth}")
        print(f"Ancho de palabra: {len(image_paths) * num_segments} bits.")

    except Exception as e:
        print(f"Error: {e}")


# --- CONFIGURACIÓN ---
escritorio = os.path.join(os.path.expanduser("~"), "OneDrive", "Escritorio")
carpeta_bmp = os.path.join(escritorio, "Textos BMP")
archivos = ["Titulo_menu.bmp",
            "Partida_comenzada.bmp"]

rutas_entrada = [os.path.join(carpeta_bmp, f) for f in archivos]
ruta_salida = os.path.join(carpeta_bmp, "Titulos.coe")

# Ejecución
multi_bmp_to_coe_segmented(rutas_entrada, ruta_salida, max_depth=1048576)