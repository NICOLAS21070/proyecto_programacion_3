defmodule ProyectoInmobiliaria.Location do

  alias ProyectoInmobiliaria.FileUtils

  # Cargar ubicaciones desde locations.dat
  def load_locations do

    case FileUtils.read_lines("data/locations.dat") do

      {:ok, locations} ->
        locations

      {:error, _reason} ->
        []

    end
  end

  # Verificar si una ubicación es válida
  def valid_location?(location) do

    normalized_input =
      String.downcase(location)

    load_locations()
    |> Enum.map(&String.downcase/1)
    |> Enum.member?(normalized_input)

  end

  # Listar ubicaciones válidas
  def list_locations do
    load_locations()
  end

end
