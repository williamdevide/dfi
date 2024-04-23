WITH
   q_target AS
   (
-- Comando SQL original - INICIO
SELECT
    alterar
    ,consultar
    ,excluir
    ,Multa
    ,Assinatura
    ,grupo
    ,empresa
    ,codigo
    ,dtinc
    ,usuario
    ,dtbaixa
    ,usuariobaixa
    ,dtalt
    ,pontuacao
    ,amparolegal
    ,localinfracao
    ,infrator
    ,dtvencimento
    ,status
    ,dtliquidacao
    ,infracaotransito
    ,infracaotransitodescricao
    ,veiculo
    ,observacao
    ,statuslancamento
    ,cnpjcpfcodigoveiculo
    ,motoristaformatado
    ,motorista
    ,nomemotorista
    ,dtinfracao
    ,moeda
    ,nome
    ,valoratevencimento
    ,valorposvencimento
    ,esferaorgaoautuador
    ,cobrardobro
    ,pagador
    ,dtrecurso
    ,dtprovimento
    ,dtindeferimento
    ,atividadeveiculo
    ,infracaotransito_amparolegal
    ,esferadescricao
    ,infratordescricao
    ,punicao
    ,gravidade
    ,numeroautoinfracao
    ,docMulta
    ,pkMulta
    ,docAssinatura
    ,pkAssinatura
    ,cidadeinfracao
    ,descricaomulta
    ,descricaoassinatura
    ,urlconsultainfracao
    ,urlconsultaboleto
    ,urlconsultaextrato
    ,numerotitulo
    ,situacao_titulo
FROM avacorpi.fnc_infracaotransito_registro_gridview(1
        ,1
        ,NULL
        ,NULL
        ,'Todos'
        ,'Todos'
        ,'Todos'
        ,'{initialDate}'
        ,NULL
        ,0
        ,3
        ,'{finalDate}'
        ,'Todas'
        ,NULL)
-- Comando SQL original - FIM
   ),
   q_filtered AS
   (
       SELECT * FROM q_target
   ),
   q_totals AS
   (
       SELECT
       COUNT(1) "__TotalOfRows_"
       FROM q_filtered
   )
SELECT *
FROM q_filtered, q_totals