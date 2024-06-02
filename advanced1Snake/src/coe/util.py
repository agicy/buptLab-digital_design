from PIL import Image


def convert_png_to_coe(input_png_path, output_coe_path) -> None:
    with Image.open(input_png_path) as img:
        img = img.convert("RGB")

        with open(output_coe_path, "w") as coe_file:
            coe_file.write("; Sample COE file with 8-bit data width\n")
            coe_file.write("memory_initialization_radix=2;\n")
            coe_file.write("memory_initialization_vector=\n")

            width, height = img.size
            for y in range(height - 1, -1, -1):
                for x in range(width):
                    r, g, b = img.getpixel((x, y))
                    r_bin = format(r >> 5, "03b")
                    g_bin = format(g >> 6, "02b")
                    b_bin = format(b >> 5, "03b")

                    rgb_bin = r_bin + g_bin + b_bin

                    if x == width - 1 and y == 0:
                        coe_file.write(f"{rgb_bin};\n")
                    else:
                        coe_file.write(f"{rgb_bin},\n")


if __name__ == "__main__":
    input_png_path = input()
    output_coe_path = input()
    convert_png_to_coe(input_png_path, output_coe_path)
