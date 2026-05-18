defmodule ProyectoInmobiliaria.ResultsLogger do

  alias ProyectoInmobiliaria.FileUtils

  # Registrar operación
  def log_operation(params) do

    date =
      Date.utc_today()
      |> Date.to_string()

    line =
      Enum.join([
        date,
        "cliente=#{params.cliente}",
        "responsable=#{params.responsable}",
        "propiedad=#{params.propiedad_id}",
        "operacion=#{params.operacion}",
        "ubicacion=#{params.ubicacion}",
        "precio=#{params.precio}",
        "status=#{params.status}"
      ], ";")

    FileUtils.write_line(
      "data/results.log",
      line
    )

  end

  # Obtener historial completo
  def get_history do

    case FileUtils.read_lines("data/results.log") do

      {:ok, lines} ->
        lines

      {:error, _reason} ->
        []

    end

  end

  # Ranking compradores
  def get_ranking_compradores do

    get_history()
    |> Enum.filter(fn line ->
      String.contains?(line, "operacion=compra")
    end)
    |> Enum.map(fn line ->
      extract_field(line, "cliente")
    end)
    |> count_occurrences()

  end

  # Ranking vendedores
  def get_ranking_vendedores do

    get_history()
    |> Enum.filter(fn line ->
      String.contains?(line, "operacion=compra")
    end)
    |> Enum.map(fn line ->
      extract_field(line, "responsable")
    end)
    |> count_occurrences()

  end

  # Ranking arrendadores
  def get_ranking_arrendadores do

    get_history()
    |> Enum.filter(fn line ->
      String.contains?(line, "operacion=arriendo")
    end)
    |> Enum.map(fn line ->
      extract_field(line, "responsable")
    end)
    |> count_occurrences()

  end

  # Extraer campo de una línea
  defp extract_field(line, field) do

    line
    |> String.split(";")
    |> Enum.find(fn part ->
      String.starts_with?(part, "#{field}=")
    end)
    |> String.replace("#{field}=", "")

  end

  # Contar ocurrencias y ordenar
  defp count_occurrences(list) do

    list
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_user, count} ->
      count
    end, :desc)

  end

end
