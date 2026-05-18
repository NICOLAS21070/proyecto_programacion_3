defmodule ProyectoInmobiliaria.PropertyManager do

  alias ProyectoInmobiliaria.FileUtils
  alias ProyectoInmobiliaria.Location

  defstruct [
    :id,
    :tipo,
    :modalidad,
    :ubicacion,
    :precio,
    :habitaciones,
    :area,
    :estado,
    :propietario
  ]

  # Convertir línea a struct
  def parse_property(line) do

    [
      id,
      tipo,
      modalidad,
      ubicacion,
      precio,
      habitaciones,
      area,
      estado,
      propietario
    ] = String.split(line, ";")

    %__MODULE__{
      id: id,
      tipo: tipo,
      modalidad: modalidad,
      ubicacion: ubicacion,
      precio: String.to_integer(precio),
      habitaciones: String.to_integer(habitaciones),
      area: String.to_float(area),
      estado: estado,
      propietario: propietario
    }

  end

  # Convertir struct a línea
  def serialize_property(property) do

    Enum.join([
      property.id,
      property.tipo,
      property.modalidad,
      property.ubicacion,
      Integer.to_string(property.precio),
      Integer.to_string(property.habitaciones),
      Float.to_string(property.area),
      property.estado,
      property.propietario
    ], ";")

  end

  # Cargar propiedades
  def load_properties do

    case FileUtils.read_lines("data/properties.dat") do

      {:ok, lines} ->
        Enum.map(lines, &parse_property/1)

      {:error, _reason} ->
        []

    end

  end

  # Buscar propiedad por ID
  def find_property(id) do

    property =
      load_properties()
      |> Enum.find(fn property ->
        property.id == id
      end)

    if property do
      {:ok, property}
    else
      {:error, :not_found}
    end

  end

  # Guardar propiedad
  def save_property(property) do

    case find_property(property.id) do

      {:ok, _property} ->
        {:error, :already_exists}

      {:error, :not_found} ->

        FileUtils.write_line(
          "data/properties.dat",
          serialize_property(property)
        )

    end

  end

  # Actualizar estado
  def update_property_state(id, new_state) do

    properties = load_properties()

    if Enum.any?(properties, fn p -> p.id == id end) do

      updated_properties =
        Enum.map(properties, fn property ->

          if property.id == id do
            %{property | estado: new_state}
          else
            property
          end

        end)

      updated_properties
      |> Enum.map(&serialize_property/1)
      |> then(fn lines ->

        FileUtils.overwrite_lines(
          "data/properties.dat",
          lines
        )

      end)

    else
      {:error, :not_found}
    end

  end

  # Listar propiedades disponibles con filtros
  def list_available(filters \\ %{}) do

    load_properties()
    |> Enum.filter(fn property ->

      property.estado == "disponible"

    end)
    |> Enum.filter(fn property ->

      tipo_ok =
        Map.get(filters, :tipo, property.tipo) == property.tipo

      modalidad_ok =
        Map.get(filters, :modalidad, property.modalidad) == property.modalidad

      ubicacion_ok =
        Map.get(filters, :ubicacion, property.ubicacion) == property.ubicacion

      precio_min_ok =
        property.precio >= Map.get(filters, :precio_min, 0)

      precio_max_ok =
        property.precio <= Map.get(filters, :precio_max, 999999999999)

      tipo_ok and modalidad_ok and ubicacion_ok and
      precio_min_ok and precio_max_ok

    end)

  end

  # Generar ID único
  def generate_id do

    "prop" <>
      Integer.to_string(
        System.unique_integer([:positive])
      )

  end

end
