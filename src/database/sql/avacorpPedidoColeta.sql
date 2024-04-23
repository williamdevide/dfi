WITH
   q_target AS
   (
-- Comando SQL original - INICIO
SELECT
    retorno.leg_semaforo
    ,retorno.leg_consultar
    ,retorno.leg_alterar
    ,retorno.leg_excluir
    ,retorno.leg_imprimir
    ,retorno.leg_duplicar
    ,retorno.leg_tipocoleta
    ,retorno.leg_situacao
    ,retorno.leg_valepedagio
    ,retorno.leg_despesaoperacional
    ,retorno.leg_embarcada
    ,retorno.grupo
    ,retorno.empresa
    ,retorno.filial
    ,retorno.unidade
    ,retorno.diferenciadornumero
    ,retorno.serie
    ,retorno.numero
    ,retorno.unidade_descricao
    ,retorno.numerofatura
    ,retorno.dtemissao
    ,retorno.dtcoletar
    ,retorno.dtinc
    ,retorno.veiculo
    ,retorno.proprietarioveiculo
    ,retorno.proprietarioveiculo_razaosocial
    ,retorno.motorista_razaosocial
    ,retorno.fone
    ,retorno.celular
    ,retorno.carreta1
    ,retorno.carreta2
    ,retorno.carreta3
    ,retorno.remetente
    ,retorno.remetente_razaosocial
    ,retorno.cidadeorigem
    ,retorno.uforigem
    ,retorno.destinatario
    ,retorno.destinatario_razaosocial
    ,retorno.cidadedestino
    ,retorno.ufdestino
    ,retorno.quantidade
    ,retorno.peso
    ,retorno.semaforo
    ,retorno.parametros_impressao
    ,retorno.nomeformulario
    ,retorno.autorformulario
    ,retorno.anolocalizador
    ,retorno.numerolocalizador
    ,retorno.nomecompletousuarioemissor
    ,retorno.nomecompletousuarioalteracao
    ,retorno.permitir_exclusao
    ,retorno.situacao
    ,retorno.permitir_alteracao
    ,retorno.permitir_imprimir
    ,retorno.veiculo_tipofrota
    ,retorno.carreta1_tipofrota
    ,retorno.carreta2_tipofrota
    ,retorno.carreta3_tipofrota
    ,retorno.remetente_desformatado
    ,retorno.utilizaritens
    ,retorno.grupocotacaofrete
    ,retorno.empresacotacaofrete
    ,retorno.filialcotacaofrete
    ,retorno.unidadecotacaofrete
    ,retorno.diferenciadornumerocotacaofrete
    ,retorno.numerocotacaofrete
    ,retorno.existedespesaoperacional
    ,retorno.tipocoleta
    ,retorno.perm_vinculardocumento
    ,retorno.permitir_duplicar
    ,retorno.sequencia_automatico
    ,retorno.pacessorapido
    ,retorno.existevalepedagio
    ,retorno.coleta_tipofrota
    ,retorno.embarcada
    ,retorno.perm_embarcar
    ,retorno.numeropedido
FROM avacorpi.fnc_coleta_gridview
(
    2
    ,1
    ,1
    ,1
    ,1
    ,'Emissao'
    ,'{initialDate}'
    ,'{finalDate}'
    ,NULL
    ,'2024'
    ,2
    ,NULL
    ,NULL
    ,1
    ,NULL
    ,NULL
    ,0
    ,0
    ,'TODOS'
    ,NULL
    ,NULL
    ,NULL
)  AS retorno
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
