defmodule ProyectoInmobiliaria.FileUtils do

  # Leer líneas de un archivo
  def read_lines(path) do
    if File.exists?(path) do
      case File.read(path) do
        {:ok, content} ->

          lines =
            content
            |> String.split("\n")
            |> Enum.map(&String.trim/1)
            |> Enum.filter(fn line -> line != "" end)

          {:ok, lines}

        {:error, reason} ->
          {:error, reason}
      end

    else
      {:error, :not_found}
    end
  end

  # Escribir una línea al final del archivo
  def write_line(path, line) do
    File.write(path, line <> "\n", [:append])
  end

  # Sobrescribir todo el archivo
  def overwrite_lines(path, lines) do

    content =
      Enum.join(lines, "\n")

    File.write(path, content <> "\n")
  end

  # Verificar si existe el archivo
  def file_exists?(path) do
    File.exists?(path)
  end

end
