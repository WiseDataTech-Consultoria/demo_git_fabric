[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared data_inicial = #date(2024, 11, 1) meta [IsParameterQuery=true, Type="Date", IsParameterQueryRequired=true];
shared data_final = DateTime.Date(DateTime.LocalNow());
shared base_transacoes = "C:\Projetos\youtube-20241111-git-github-main\transacoes.xlsx" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "calendario_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared calendario = let
    dataInicial = data_inicial, 
    dataFinal = data_final, 
    
    datas = List.Dates(
        dataInicial, 
        Duration.Days(dataFinal-dataInicial) + 1, 
        #duration(1, 0, 0, 0)
    ),

    calendario = #table(
        type table[
            Data = date,
            Ano = Int64.Type,
            MesAno = text,
            MesInicio = date
        ],
        List.Transform(
            datas,
            each {
                _,
                Date.Year(_),
                Date.ToText(_, [Format="MMM/yy", Culture="pt-BR"]),
                Date.StartOfMonth(_)
            }
        )
    )

in
    calendario;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "transacoes_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared transacoes = let
    source = Excel.Workbook(
        File.Contents(base_transacoes), 
        true, 
        null
    ),
    
    transacoes_Table = source{[Item="transacoes",Kind="Table"]}[Data],
    
    datesRestricted = Table.SelectRows(
        transacoes_Table, 
        each [Data] >= data_inicial and [Data] <= data_final
    )
in
    datesRestricted;
shared calendario_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "2c0d3e32-e676-4630-9b09-65abc777de0c"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "6450f0af-ea66-4e55-a73b-2b4b1311b19d"]}[Data],
  TableNavigation = Navigation_2{[Id = "calendario", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared transacoes_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "2c0d3e32-e676-4630-9b09-65abc777de0c"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "6450f0af-ea66-4e55-a73b-2b4b1311b19d"]}[Data],
  TableNavigation = Navigation_2{[Id = "transacoes", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
