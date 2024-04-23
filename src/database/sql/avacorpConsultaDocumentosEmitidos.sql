WITH
   q_target AS
   (
-- Comando SQL original - INICIO
SELECT retorno.*

FROM(

SELECT
            '' AS leg_sac,
    CASE COALESCE(conhecimento.tipofrota, veiculo.tipofrota)
        WHEN 1 THEN
            ' Própria'
        WHEN 2 THEN
            ' Terceiro'
        WHEN 3 THEN
            ' Agregado'
        ELSE
            ' Sem Veículo'
    END AS tipofrota,
    'CT-e'::VARCHAR AS tipodocumento,
    conhecimento.grupo,
    grupo.nome AS nomegrupo,
    conhecimento.empresa,
    empresa.nome AS nomeempresa,
    conhecimento.filial,
    filial.apelido AS apelidofilial,
    conhecimento.unidade,
    unidade.descricao AS unidadedescricao,
    conhecimento.tipofrete,
    tipofrete.descricao AS tipofretedescricao,
    conhecimento.tipocarga,
    tipocarga.descricao AS tipocargadescricao,
    conhecimento.numero::VARCHAR AS numero,

    conhecimento.dtemissao,

    conhecimento.dtprevisaoentrega,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(conhecimento.remetente),'') AS cpfcnpjremetente,
    cadastro.razaosocial AS razaoremetente,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(conhecimento.destinatario),'') AS cpfcnpjdestinatario,
    cadastro_1.razaosocial AS razaodestinatario,
    COALESCE(conhecimento.consignatario,'') AS consignatario,
    cadastro_2.razaosocial AS razaoconsignatario,
    conhecimento.cidadecoleta,
    conhecimento.ufcoleta,
    conhecimento.cidadeentrega,
    conhecimento.ufentrega,
    conhecimento.veiculo,
    COALESCE(conhecimento.quantidade,0) AS quantidade,
    COALESCE(conhecimento.m3,0) AS m3,
    COALESCE(conhecimento.peso,0) AS peso,
    COALESCE(conhecimento.valoricms,0) + COALESCE(conhecimento.valoricmssubstituicaotributaria,0) + COALESCE(conhecimento.valoricmspartilha,0) + COALESCE(conhecimento.valoricmsoutrauf,0) + COALESCE(conhecimento.valoricmsclienteregimedistintoobservacaoicms,0) AS valoricms,
    COALESCE(conhecimento.valoriss,0) AS valoriss,
    COALESCE(conhecimento.valortotalmercadoria,0) AS valortotalmercadoria,
    COALESCE(conhecimento.valortotalprestacao,0) AS valortotalprestacao,
    (COALESCE(conhecimento.valortotalprestacao,0)  -
    (COALESCE(conhecimento.valoricms,0) + COALESCE(conhecimento.valoricmssubstituicaotributaria,0) + COALESCE(conhecimento.valoricmspartilha,0) + COALESCE(conhecimento.valoricmsoutrauf,0) + COALESCE(conhecimento.valoricmsclienteregimedistintoobservacaoicms,0) + COALESCE(conhecimento.valortaxapedagio,0))) AS valor_liquido,

    CASE WHEN conhecimento.pagadorfrete = 1 THEN 'CIF' ELSE 'FOB' END AS pagadorfrete,
    conhecimento.dtcancelamento,
    COALESCE(ARRAY_TO_STRING(ARRAY_ADD(DISTINCT conhecimento_notafiscal.numeronotafiscal::VARCHAR),', '),'') AS notas,

    COALESCE(ARRAY_TO_STRING(ARRAY_ADD(DISTINCT conhecimento_notafiscal_item.produtodescricao),', '),'')||COALESCE(ARRAY_TO_STRING(ARRAY_ADD(DISTINCT conhecimento_notafiscal.naturezamercadoria),', '),'') AS produto,

    filialdestino.apelido AS nomefilialdestino,
    unidadedestino.descricao AS nomeunidadedestino,
    tipofretecapa.descricao AS tipofretemodalcapa,
    conhecimento.pesobalanca AS pesoaferido,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT vendedor.razaosocial),', ')   AS vendedor,
    pagadorfrete.razaosocial AS razaosocial_pagadorfrete
    ,conhecimento.valortaxapedagio
    ,COALESCE(conhecimento.pesoliquido,0) AS pesoliquido
    ,conhecimento_endereco.endereco || ' nº '|| conhecimento_endereco.numeroendereco AS enderecodestinatario
    ,conhecimento_endereco.complemento
    ,1::INT AS permitesac
    ,6::INT AS tipodocumentocod
    ,conhecimento.carreta1 AS carreta1
    ,conhecimento.carreta2 AS carreta2
    ,conhecimento.carreta3 AS carreta3
    ,motorista.razaosocial AS motorista_razao
    ,conhecimento.dtemissao::DATE AS dtemi
    ,COALESCE(ARRAY_TO_STRING(ARRAY_ADD(DISTINCT conhecimento_notafiscal.numeropedido::VARCHAR),','),'') AS nropedido,
    CASE WHEN conhecimento.tipo = 1 AND conhecimento.complementar = 2 AND conhecimento.complementarimposto = 2 THEN
            'Normal'
    WHEN conhecimento.tipo =  2 THEN
            'Entrada'
    WHEN conhecimento.tipo = 3 AND conhecimento.complementar = 2 AND conhecimento.complementarimposto = 2 THEN
            'Substituído'
    WHEN conhecimento.tipo = 4 AND conhecimento.complementar = 2 AND conhecimento.complementarimposto = 2 THEN
            'Substituto'
    WHEN conhecimento.tipo = 5 AND conhecimento.complementar = 2 AND conhecimento.complementarimposto = 2 THEN
            'Multimodal'
    WHEN conhecimento.tipo = 6 AND conhecimento.complementar = 2 AND conhecimento.complementarimposto = 2 THEN
            'Entrada(Tomador)'
    WHEN conhecimento.tipo = 7 AND conhecimento.complementar = 2 AND conhecimento.complementarimposto = 2 THEN
            'Substituto(Tomador)'
    WHEN conhecimento.complementar = 1 AND conhecimento.complementarimposto = 2 THEN
            'Complementar de Frete'
    WHEN conhecimento.complementarimposto = 1 THEN
            'Complementar de Imposto'
    END AS tipo
    ,conhecimento.chaveacessocte

    ,CASE WHEN conhecimento.complementar = 1 OR conhecimento.tipo IN (4,7) THEN conhecimento.numeroctrcorigem ELSE NULL END AS numerodocumentoorigem
    ,CASE WHEN conhecimento.complementar = 1 OR conhecimento.tipo IN (4,7) THEN conhecimento.filialctrcorigem ELSE NULL END AS filialdocumentoorigem
    ,CASE WHEN conhecimento.complementar = 1 OR conhecimento.tipo IN (4,7) THEN conhecimento.unidadectrcorigem ELSE NULL END AS unidadedocumentoorigem
    ,COALESCE(ARRAY_TO_STRING(ARRAY_ADD(DISTINCT cte_origem_notafiscal.numeronotafiscal::VARCHAR),', '),'') AS notasfiscaisdocumentoorigem
    ,conhecimento.serie as conhecimentoserie
    ,conhecimento.valorreceber
    ,serie.serie
    ,conhecimento.usuarioemissor
    ,usuario_emissor.nomecompleto AS nomecompletoemissor
    ,coleta.kmfrete
    ,conhecimento.diferenciadornumero AS diferenciadornumero
    ,NULL::INT AS sequencia
    ,coleta.numero as coleta
    ,coleta.trajeto AS trajeto
    ,trajeto.descricao AS trajeto_descricao
    ,veiculo.tipoveiculo
    ,veiculo.numerofrota
    ,conhecimento.numero::VARCHAR AS numero_exibir

FROM conhecimento

JOIN avacorpi.tipoconhecimento
ON avacorpi.tipoconhecimento.id = conhecimento.tipo

LEFT JOIN conhecimento_composicao
    ON conhecimento_composicao.grupo = conhecimento.grupo
    AND conhecimento_composicao.empresa = conhecimento.empresa
    AND conhecimento_composicao.filial = conhecimento.filial
    AND conhecimento_composicao.unidade = conhecimento.unidade
    AND conhecimento_composicao.diferenciadornumero = conhecimento.diferenciadornumero
    AND conhecimento_composicao.serie = conhecimento.serie
    AND conhecimento_composicao.numero = conhecimento.numero

LEFT JOIN coleta
    ON coleta.grupo = conhecimento_composicao.grupo
    AND coleta.empresa = conhecimento_composicao.empresa
    AND coleta.filial = conhecimento_composicao.filialdocumento
    AND coleta.unidade = conhecimento_composicao.unidadedocumento
    AND coleta.diferenciadornumero = conhecimento_composicao.diferenciadornumerodocumento
    AND coleta.serie = conhecimento_composicao.seriedocumento
    AND coleta.numero = conhecimento_composicao.numerodocumento

LEFT JOIN conhecimento_comissao ON conhecimento_comissao.grupo = conhecimento.grupo
AND conhecimento_comissao.empresa = conhecimento.empresa
AND conhecimento_comissao.filial = conhecimento.filial
AND conhecimento_comissao.unidade = conhecimento.unidade
AND conhecimento_comissao.diferenciadornumero = conhecimento.diferenciadornumero
AND conhecimento_comissao.serie = conhecimento.serie
AND conhecimento_comissao.numero = conhecimento.numero

LEFT JOIN cadastro vendedor ON vendedor.codigo = conhecimento_comissao.cnpjcpfcodigovendedor

LEFT JOIN cadastro motorista
    ON motorista.codigo = conhecimento.motorista

LEFT JOIN usuario usuario_emissor
    ON usuario_emissor.codigo = conhecimento.usuarioemissor

JOIN grupo ON conhecimento.grupo=grupo.codigo

JOIN empresa ON conhecimento.grupo=empresa.grupo AND conhecimento.empresa=empresa.codigo

JOIN serie ON conhecimento.grupo=serie.grupo AND conhecimento.empresa=serie.empresa AND conhecimento.serie=serie.codigo

LEFT OUTER JOIN filial ON conhecimento.grupo=filial.grupo
                                     AND conhecimento.empresa=filial.empresa
                                     AND conhecimento.filial=filial.codigo

LEFT OUTER JOIN unidade ON conhecimento.grupo=unidade.grupo
                           AND conhecimento.empresa=unidade.empresa
                  AND conhecimento.filial=unidade.filial
                  AND conhecimento.unidade=unidade.codigo

LEFT OUTER JOIN cadastro ON conhecimento.remetente=cadastro.codigo

LEFT OUTER JOIN cadastro cadastro_1 ON conhecimento.destinatario=cadastro_1.codigo

LEFT OUTER JOIN cadastro cadastro_2 ON conhecimento.consignatario=cadastro_2.codigo

LEFT JOIN veiculo
    ON veiculo.placa = conhecimento.veiculo

JOIN cadastro pagadorfrete ON pagadorfrete.codigo = conhecimento.cnpjcpfcodigopagadorfrete

LEFT OUTER JOIN tipofrete
ON  tipofrete.grupo  = conhecimento.grupo
AND tipofrete.empresa  = conhecimento.empresa
AND tipofrete.codigo = conhecimento.tipofrete

LEFT OUTER JOIN tipocarga
ON  tipocarga.grupo  = conhecimento.grupo
AND tipocarga.empresa  = conhecimento.empresa
AND tipocarga.codigo = conhecimento.tipocarga

LEFT JOIN tipofrete tipofretecapa ON tipofretecapa.codigo = COALESCE(0,0)


LEFT JOIN filial filialdestino ON filialdestino.grupo = 1
                              AND filialdestino.empresa = 1
                              AND filialdestino.codigo = COALESCE(0,0)


LEFT JOIN unidade unidadedestino ON unidadedestino.grupo = 1
                              AND unidadedestino.empresa = 1
                              AND unidadedestino.filial = COALESCE(0,0)
                              AND unidadedestino.codigo = COALESCE(0,0)




LEFT OUTER JOIN conhecimento_notafiscal ON conhecimento.grupo = conhecimento_notafiscal.grupo
                                             AND conhecimento.empresa = conhecimento_notafiscal.empresa
                                             AND conhecimento.filial = conhecimento_notafiscal.filial
                                             AND conhecimento.unidade = conhecimento_notafiscal.unidade
                                             AND conhecimento.diferenciadornumero = conhecimento_notafiscal.diferenciadornumero
                                             AND conhecimento.serie = conhecimento_notafiscal.serie
                                             AND conhecimento.numero = conhecimento_notafiscal.numero

LEFT OUTER JOIN conhecimento_notafiscal_item ON conhecimento.grupo = conhecimento_notafiscal_item.grupo
                                             AND conhecimento.empresa = conhecimento_notafiscal_item.empresa
                                             AND conhecimento.filial = conhecimento_notafiscal_item.filial
                                             AND conhecimento.unidade = conhecimento_notafiscal_item.unidade
                                             AND conhecimento.diferenciadornumero = conhecimento_notafiscal_item.diferenciadornumero
                                             AND conhecimento.serie = conhecimento_notafiscal_item.serie
                                             AND conhecimento.numero = conhecimento_notafiscal_item.numero
                                             AND conhecimento_notafiscal.numeronotafiscal = conhecimento_notafiscal_item.numeronotafiscal

LEFT JOIN conhecimento_endereco ON conhecimento_endereco.grupo = conhecimento.grupo
                                AND conhecimento_endereco.empresa = conhecimento.empresa
                                AND conhecimento_endereco.filial = conhecimento.filial
                                AND conhecimento_endereco.unidade = conhecimento.unidade
                                AND conhecimento_endereco.diferenciadornumero = conhecimento.diferenciadornumero
                                AND conhecimento_endereco.serie = conhecimento.serie
                                AND conhecimento_endereco.numero = conhecimento.numero
                                AND conhecimento_endereco.tipo = 2

LEFT JOIN naturezamercadoria
ON naturezamercadoria.grupo = conhecimento.grupo
AND naturezamercadoria.empresa = conhecimento.empresa
AND naturezamercadoria.descricao = conhecimento_notafiscal.naturezamercadoria

LEFT JOIN conhecimento_notafiscal cte_origem_notafiscal
ON cte_origem_notafiscal.grupo = conhecimento.grupo
AND cte_origem_notafiscal.empresa = conhecimento.empresa
AND cte_origem_notafiscal.filial = conhecimento.filialctrcorigem
AND cte_origem_notafiscal.unidade = conhecimento.unidadectrcorigem
AND cte_origem_notafiscal.diferenciadornumero = conhecimento.diferenciadornumeroctrcorigem
AND cte_origem_notafiscal.serie = conhecimento.seriectrcorigem
AND cte_origem_notafiscal.numero = conhecimento.numeroctrcorigem

LEFT JOIN trajeto
    ON  trajeto.grupo = coleta.grupo
    AND trajeto.empresa = coleta.empresa
    AND trajeto.codigo = coleta.trajeto



WHERE conhecimento.grupo = 1
AND conhecimento.empresa = 1
AND (COALESCE(1,0) = 0 OR conhecimento.filial = COALESCE(1,0))
AND (COALESCE(1,0) = 0 OR conhecimento.unidade = COALESCE(1,0))
AND (COALESCE(0,0) = 0 OR conhecimento.filialdestino = 0)
AND (COALESCE(0,0)= 0 OR conhecimento.unidadedestino = 0)
AND conhecimento.numero<1000000
AND (conhecimento.dtemissao BETWEEN ('{initialDate}'||' '||'00:00:00')::timestamp AND ('{finalDate}'||' '||'23:59:00')::timestamp)
AND conhecimento.dtcancelamento IS NULL
AND (CASE WHEN 'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' <>'' THEN
        CASE WHEN 'Sim' = 'Sim' THEN
           (SUBSTR(conhecimento.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(conhecimento.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(conhecimento.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8))
        ELSE
           (conhecimento.remetente = FNC_DESFORMATA_CAMPO('') OR
            conhecimento.destinatario = FNC_DESFORMATA_CAMPO('') OR
            conhecimento.consignatario = FNC_DESFORMATA_CAMPO(''))
        END
     ELSE
        (CASE WHEN  'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' = '' THEN
            TRUE
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Remetente' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(conhecimento.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               conhecimento.remetente = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Destinatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(conhecimento.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               conhecimento.destinatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Consignatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(conhecimento.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               conhecimento.consignatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Pagador do Frete' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(conhecimento.cnpjcpfcodigopagadorfrete,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               conhecimento.cnpjcpfcodigopagadorfrete = FNC_DESFORMATA_CAMPO('')
            END
         END)
     END)
AND (COALESCE(0,0) = 0 OR conhecimento.tipofrete = 0)
AND (COALESCE(0,0) = 0 OR conhecimento.tipocarga = 0)
AND CASE WHEN conhecimento.emissaoeletronica = 1 THEN conhecimento.situacaocte = 3 ELSE TRUE END
AND ('' = '' OR conhecimento_notafiscal_item.produtocliente = '')
AND ('Todos' = 'Todos' OR 'Todos' = 'CT-e' OR 'Todos' = 'Complementarimposto' OR 'Todos' = 'Complementar')
AND ('' = '' OR conhecimento.veiculo = UPPER(''))
AND (CASE WHEN 'Todos' = 'Todos' THEN
            TRUE
           WHEN 'Todos' = 'CIF' THEN
             conhecimento.pagadorfrete = 1
           WHEN 'Todos' = 'FOB' THEN
            conhecimento.pagadorfrete > 1
     END)
AND CASE WHEN 'Sim' = 'Sim' OR 'Todos' = 'Complementarimposto' OR 'Todos' = 'Complementar' THEN TRUE ELSE conhecimento.complementar = 2 END
AND CASE WHEN 'Todos' = 'Complementarimposto' THEN conhecimento.complementarimposto = 1 ELSE TRUE END
AND CASE WHEN 'Todos' = 'Complementar' THEN conhecimento.complementar = 1 ELSE TRUE END
AND ('' = '' OR conhecimento.motorista = FNC_DESFORMATA_CAMPO(''))
AND CASE WHEN COALESCE('','') = '' THEN TRUE ELSE conhecimento_notafiscal.naturezamercadoria = '' END
AND CASE
        WHEN 'Todos' = 'Todos' THEN TRUE
        WHEN 'Todos' = 'Sim' THEN naturezamercadoria.quimico = 1
        WHEN 'Todos' = 'Não' THEN naturezamercadoria.quimico = 2
        END
AND (COALESCE('','') = '' OR conhecimento_notafiscal.numeropedido = '')
AND CASE WHEN 'Sim' = 'Sim' OR 'Todos' = 'Entrada' THEN TRUE ELSE conhecimento.tipo in (1,3,4,5,6,7) AND conhecimento.complementar IN (1,2)  END
AND CASE WHEN 'Todas' = 'Própria' THEN
            COALESCE(conhecimento.tipofrota,veiculo.tipofrota) = 1
     WHEN 'Todas' = 'Terceiro' THEN
            COALESCE(conhecimento.tipofrota,veiculo.tipofrota) = 2
     WHEN 'Todas' = 'Agregado' THEN
            COALESCE(conhecimento.tipofrota,veiculo.tipofrota) = 3
     ELSE
         TRUE
     END



GROUP BY
1,2,3,4,5,6,7,8,9,10,
11,12,13,14,15,16,17,18,19,20,
21,22,23,24,25,26,27,28,29,30,
31,32,33,34,35,36,37,38,39,
42,43,44,45,47,48,49,
50,51,53,54,55,56,57,58,60,
61,62,63,64,66,67,68,69,70,
71,72,73,74,75,76,77,78




-------------------------------------------------    RECIBOS  RECIBOS
UNION ALL


SELECT
    '' AS leg_sac,
    CASE COALESCE(recibo.tipofrota, veiculo.tipofrota)
        WHEN 1 THEN
            ' Própria'
        WHEN 2 THEN
            ' Terceiro'
        WHEN 3 THEN
            ' Agregado'
    END AS tipofrota,
    'REC'::VARCHAR AS tipodocumento,

    recibo.grupo,
    grupo.nome AS nomegrupo,
    recibo.empresa,
    empresa.nome AS nomeempresa,
    recibo.filial,
    filial.apelido AS apelidofilial,
    recibo.unidade,
    unidade.descricao AS unidadedescricao,
    recibo.tipofrete,
    tipofrete.descricao AS tipofretedescricao,
    recibo.tipocarga AS tipocarga,
    tipocarga.descricao AS tipocargadescricao,
    recibo.numero::VARCHAR AS numero,
    recibo.dtemissao AS dtemissao,
    recibo.dtprevisaoentrega,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(recibo.remetente),'') AS cpfcnpjremetente,
    cadastro.razaosocial AS razaoremetente,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(recibo.destinatario),'') AS cpfcnpjdestinatario,
    cadastro_1.razaosocial AS razaodestinatario,
    COALESCE(recibo.consignatario,'') AS consignatario,
    cadastro_2.razaosocial AS razaoconsignatario,
    recibo.cidadecoleta,
    recibo.ufcoleta,
    recibo.cidadeentrega,
    recibo.ufentrega,
    recibo.veiculo,
    COALESCE(recibo.quantidade,0) AS quantidade,
    COALESCE(recibo.m3,0) AS m3,
    COALESCE(recibo.peso,0) AS peso,
    0::NUMERIC AS valoricms,
    0::NUMERIC AS valoriss,
    COALESCE(recibo.valortotalmercadoria,0) AS valortotalmercadoria,
    COALESCE(recibo.valortotalprestacao,0) AS valortotalprestacao,
    (COALESCE(recibo.valortotalprestacao,0) - COALESCE(recibo.valortaxapedagio,0)) AS valor_liquido,
    CASE WHEN recibo.pagadorfrete = 1 THEN 'CIF' ELSE 'FOB' END AS pagadorfrete,
    recibo.dtcancelamento,
    fnc_busca_notas_documentos(recibo.grupo,
                                                      recibo.empresa,
                                                      recibo.filial,
                                                      recibo.unidade,
                                                      recibo.diferenciadornumero,
                                                      recibo.serie,
                                                      recibo.numero,
                                                      null,
                                                      null,
                                                      recibo.tipodocumento) AS notas,
    COALESCE(ARRAY_TO_STRING(ARRAY_ADD(DISTINCT recibo_notafiscal_item.produtodescricao),', '),'')||COALESCE(ARRAY_TO_STRING(ARRAY_ADD(DISTINCT recibo_notafiscal.naturezamercadoria),', '),'')   AS produto,

    filialdestino.apelido AS nomefilialdestino,
    unidadedestino.descricao AS nomeunidadedestino,
    tipofretecapa.descricao AS tipofretemodalcapa,
    0::numeric AS pesoaferido,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT vendedor.razaosocial),', ')   AS vendedor,
    pagadorfrete.razaosocial AS razaosocial_pagadorfrete
    ,recibo.valortaxapedagio
    ,COALESCE(recibo.peso,0) AS pesoliquido
    ,recibo_endereco.endereco || ' nº ' || recibo_endereco.numeroendereco AS enderecodestinatario
    ,recibo_endereco.complemento
    ,2::INT AS permitesac
    ,8::INT AS tipodocumentocod
    ,recibo.carreta1 AS carreta1
    ,recibo.carreta2 AS carreta2
    ,recibo.carreta3 AS carreta3
    ,motorista.razaosocial AS motorista_razao,
    recibo.dtemissao::DATE AS dtemi,
    COALESCE(ARRAY_TO_STRING(ARRAY_ADD(DISTINCT recibo_notafiscal.numeropedido::VARCHAR),','),'') AS nropedido,
    CASE WHEN recibo.complementar  = 2 THEN 'Normal' ELSE 'Complementar de Frete' END  AS tipo
    ,NULL as chaveacessocte
    ,NULL::integer AS numerodocumentoorigem
    ,NULL::integer AS filialdocumentoorigem
    ,NULL::integer AS unidadedocumentoorigem
    ,'' AS notasfiscaisdocumentoorigem
    ,recibo.serie
    ,recibo.valortotalprestacao AS valorreceber
    ,NULL as serie
    ,recibo.usuarioemissor
    ,usuario_emissor.nomecompleto AS nomecompletoemissor
    ,NULL::integer AS kmfrete
    ,recibo.diferenciadornumero AS diferenciadornumero
    ,NULL::INT AS sequencia
    ,coleta.numero as coleta
    ,recibo.trajeto AS trajeto
    ,trajeto.descricao AS trajeto_descricao
    ,veiculo.tipoveiculo
    ,veiculo.numerofrota
    ,recibo.numero::VARCHAR AS numero_exibir
FROM recibo

LEFT JOIN recibo_comissao ON recibo_comissao.grupo = recibo.grupo
AND recibo_comissao.empresa = recibo.empresa
AND recibo_comissao.filial = recibo.filial
AND recibo_comissao.unidade = recibo.unidade
AND recibo_comissao.diferenciadornumero = recibo.diferenciadornumero
AND recibo_comissao.serie = recibo.serie
AND recibo_comissao.numero = recibo.numero

LEFT JOIN cadastro vendedor ON vendedor.codigo = recibo_comissao.cnpjcpfcodigovendedor

LEFT JOIN cadastro motorista
    ON motorista.codigo = recibo.motorista

LEFT JOIN usuario usuario_emissor
        ON usuario_emissor.codigo = recibo.usuarioemissor

JOIN grupo ON recibo.grupo=grupo.codigo

JOIN empresa ON recibo.grupo=empresa.grupo AND recibo.empresa=empresa.codigo

LEFT OUTER JOIN filial ON recibo.grupo=filial.grupo
                                     AND recibo.empresa=filial.empresa
                                     AND recibo.filial=filial.codigo

LEFT OUTER JOIN unidade ON recibo.grupo=unidade.grupo
                           AND recibo.empresa=unidade.empresa
                  AND recibo.filial=unidade.filial
                  AND recibo.unidade=unidade.codigo

LEFT OUTER JOIN cadastro ON recibo.remetente=cadastro.codigo

LEFT OUTER JOIN cadastro cadastro_1 ON recibo.destinatario=cadastro_1.codigo

LEFT OUTER JOIN cadastro cadastro_2 ON recibo.consignatario=cadastro_2.codigo

LEFT JOIN veiculo
    ON veiculo.placa = recibo.veiculo

JOIN cadastro pagadorfrete ON pagadorfrete.codigo = recibo.cnpjcpfcodigopagadorfrete

LEFT OUTER JOIN tipofrete
ON  tipofrete.grupo  = recibo.grupo
AND tipofrete.empresa  = recibo.empresa
AND tipofrete.codigo = recibo.tipofrete

LEFT JOIN tipocarga
    ON  tipocarga.grupo  = recibo.grupo
    AND tipocarga.empresa  = recibo.empresa
    AND tipocarga.codigo = recibo.tipocarga

LEFT JOIN filial filialdestino ON filialdestino.grupo = 1
                              AND filialdestino.empresa = 1
                              AND filialdestino.codigo = COALESCE(0,0)


LEFT JOIN unidade unidadedestino ON unidadedestino.grupo = 1
                              AND unidadedestino.empresa = 1
                              AND unidadedestino.filial = COALESCE(0,0)
                              AND unidadedestino.codigo = COALESCE(0,0)




LEFT JOIN tipofrete tipofretecapa ON tipofretecapa.codigo = COALESCE(0,0)

LEFT OUTER JOIN recibo_notafiscal ON recibo.grupo = recibo_notafiscal.grupo
                                             AND recibo.empresa = recibo_notafiscal.empresa
                                             AND recibo.filial = recibo_notafiscal.filial
                                             AND recibo.unidade = recibo_notafiscal.unidade
                                             AND recibo.diferenciadornumero = recibo_notafiscal.diferenciadornumero
                                             AND recibo.serie = recibo_notafiscal.serie
                                             AND recibo.numero = recibo_notafiscal.numero

LEFT OUTER JOIN recibo_notafiscal_item ON recibo.grupo = recibo_notafiscal_item.grupo
                                             AND recibo.empresa = recibo_notafiscal_item.empresa
                                             AND recibo.filial = recibo_notafiscal_item.filial
                                             AND recibo.unidade = recibo_notafiscal_item.unidade
                                             AND recibo.diferenciadornumero = recibo_notafiscal_item.diferenciadornumero
                                             AND recibo.serie = recibo_notafiscal_item.serie
                                             AND recibo.numero = recibo_notafiscal_item.numero

LEFT JOIN recibo_endereco ON recibo_endereco.grupo = recibo.grupo
                            AND recibo_endereco.empresa = recibo.empresa
                            AND recibo_endereco.filial = recibo.filial
                            AND recibo_endereco.unidade = recibo.unidade
                            AND recibo_endereco.diferenciadornumero = recibo.diferenciadornumero
                            AND recibo_endereco.serie = recibo.serie
                            AND recibo_endereco.numero = recibo.numero
                            AND recibo_endereco.tipo = 2

LEFT JOIN naturezamercadoria
ON naturezamercadoria.grupo = recibo.grupo
AND naturezamercadoria.empresa = recibo.empresa
AND naturezamercadoria.descricao = recibo_notafiscal.naturezamercadoria

LEFT JOIN coleta
    ON coleta.grupo = recibo.grupo
    AND coleta.empresa = recibo.empresa
    AND coleta.filial = recibo.filial
    AND coleta.unidade = recibo.unidade
    AND coleta.diferenciadornumero = recibo.diferenciadornumero
    AND coleta.serie = recibo.serie
    AND coleta.numero = recibo.numero

LEFT JOIN trajeto
    ON  trajeto.grupo = recibo.grupo
    AND trajeto.empresa = recibo.empresa
    AND trajeto.codigo = recibo.trajeto



WHERE recibo.grupo = 1
AND recibo.empresa = 1
AND (COALESCE(1,0) = 0 OR recibo.filial = 1)
AND (COALESCE(1,0) = 0 OR recibo.unidade = 1)
AND (COALESCE(0,0) = 0 OR recibo.filialdestino = 0)
AND (COALESCE(0,0)= 0 OR recibo.unidadedestino = 0)
AND recibo.numero<1000000
AND (recibo.dtemissao BETWEEN ('{initialDate}'||' '||'00:00:00')::timestamp AND ('{finalDate}'||' '||'23:59:00')::timestamp)
AND recibo.dtcancelamento IS NULL
AND (CASE WHEN 'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' <>'' THEN
        CASE WHEN 'Sim' = 'Sim' THEN
           (SUBSTR(recibo.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(recibo.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(recibo.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8))
        ELSE
           (recibo.remetente = FNC_DESFORMATA_CAMPO('') OR
            recibo.destinatario = FNC_DESFORMATA_CAMPO('') OR
            recibo.consignatario = FNC_DESFORMATA_CAMPO(''))
        END
     ELSE
        (CASE WHEN  'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' = '' THEN
            TRUE
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Remetente' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(recibo.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               recibo.remetente = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Destinatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(recibo.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               recibo.destinatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Consignatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(recibo.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               recibo.consignatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Pagador do Frete' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(recibo.cnpjcpfcodigopagadorfrete,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               recibo.cnpjcpfcodigopagadorfrete = FNC_DESFORMATA_CAMPO('')
            END
         END)
     END)
AND (COALESCE(0,0) = 0 OR recibo.tipofrete = 0)
AND ('' = '' OR recibo_notafiscal_item.produtocliente = '')
AND ('Todos' = 'Todos' OR 'Todos' = 'Recibo')
AND ('' = '' OR recibo.veiculo = UPPER(''))
AND (CASE WHEN 'Todos' = 'Todos' THEN
            TRUE
           WHEN 'Todos' = 'CIF' THEN
             recibo.pagadorfrete = 1
           WHEN 'Todos' = 'FOB' THEN
            recibo.pagadorfrete > 1
     END)

AND ('' = '' OR recibo.motorista = FNC_DESFORMATA_CAMPO(''))
AND CASE WHEN COALESCE('','') = '' THEN TRUE ELSE recibo_notafiscal.naturezamercadoria = '' END
AND CASE
        WHEN 'Todos' = 'Todos' THEN TRUE
        WHEN 'Todos' = 'Sim' THEN naturezamercadoria.quimico = 1
        WHEN 'Todos' = 'Não' THEN naturezamercadoria.quimico = 2
        END
AND (COALESCE('','') = '' OR recibo_notafiscal.numeropedido = '')
AND CASE WHEN 'Todas' = 'Própria' THEN
            COALESCE(recibo.tipofrota,veiculo.tipofrota) = 1
     WHEN 'Todas' = 'Terceiro' THEN
            COALESCE(recibo.tipofrota,veiculo.tipofrota) = 2
     WHEN 'Todas' = 'Agregado' THEN
            COALESCE(recibo.tipofrota,veiculo.tipofrota) = 3
     ELSE
         TRUE
     END


GROUP BY
1,2,3,4,5,6,7,8,9,10,
11,12,13,14,15,16,17,18,19,20,
21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,43,44,45,47,48,49,50,51,53,54,55,56,57,58,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78


---------------------------------------------------- REDESPACHO  REDESPACHO  REDESPACHO  REDESPACHO ------------------------------------------------------------

UNION ALL


SELECT
    '' AS leg_sac,
    CASE COALESCE(redespacho.tipofrota, veiculo.tipofrota)
        WHEN 1 THEN
            ' Própria'
        WHEN 2 THEN
            ' Terceiro'
        WHEN 3 THEN
            ' Agregado'
    END AS tipofrota,
    'RED'::VARCHAR AS tipodocumento,

    redespacho.grupo,
    grupo.nome AS nomegrupo,
    redespacho.empresa,
    empresa.nome AS nomeempresa,
    redespacho.filial,
    filial.apelido AS apelidofilial,
    redespacho.unidade,
    unidade.descricao AS unidadedescricao,
    redespacho.tipofrete,
    tipofrete.descricao AS tipofretedescricao,
    NULL::integer AS tipocarga,
    ''::VARCHAR AS tipocargadescricao,
    redespacho.numero::VARCHAR AS numero,

    redespacho.dtemissao,
    redespacho.dtprevisaoentrega,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(redespacho.remetente),'') AS cpfcnpjremetente,
    cadastro.razaosocial AS razaoremetente,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(redespacho.destinatario),'') AS cpfcnpjdestinatario,
    cadastro_1.razaosocial AS razaodestinatario,
    COALESCE(redespacho.consignatario,'') AS consignatario,
    cadastro_2.razaosocial AS razaoconsignatario,
    redespacho.cidadecoleta,
    redespacho.ufcoleta,
    redespacho.cidadeentrega,
    redespacho.ufentrega,
    redespacho.veiculo,
    COALESCE(redespacho.quantidade,0) AS quantidade,
    COALESCE(redespacho.m3,0) AS m3,
    COALESCE(redespacho.peso,0) AS peso,
    0::NUMERIC AS valoricms,
    0::NUMERIC AS valoriss,
    COALESCE(redespacho.valortotalmercadoria,0) AS valortotalmercadoria,
    COALESCE(redespacho.valortotalprestacao,0) AS valortotalprestacao,
    (COALESCE(redespacho.valortotalprestacao,0) - COALESCE(redespacho.valortaxapedagio,0)) AS valor_liquido,
    CASE WHEN redespacho.pagadorfrete = 1 THEN 'CIF' ELSE 'FOB' END AS pagadorfrete,
    NULL::DATE AS dtcancelamento,
    fnc_busca_notas_documentos(redespacho.grupo,
                                                      redespacho.empresa,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      redespacho.serie,
                                                      redespacho.numero,
                                                      redespacho.cnpjcpfcodigoemissor,
                                                      redespacho.dtemissao,
                                                      redespacho.tipodocumento) AS notas,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT redespacho_notafiscal_item.produtodescricao),', ')   AS produto,
    filialdestino.apelido AS nomefilialdestino,
    unidadedestino.descricao AS nomeunidadedestino,
    tipofretecapa.descricao AS tipofretemodalcapa,
    0::numeric AS pesoaferido,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT vendedor.razaosocial),', ')   AS vendedor,
    pagadorfrete.razaosocial AS razaosocial_pagadorfrete
    ,redespacho.valortaxapedagio
    ,COALESCE(redespacho.peso,0) AS pesoliquido
    ,redespacho_endereco.endereco || ' nº ' || redespacho_endereco.numeroendereco AS enderecodestinatario
    ,redespacho_endereco.complemento
    ,2::INT AS permitesac
    ,11::INT AS tipodocumentocod
    ,redespacho.carreta1 AS carreta1
    ,redespacho.carreta2 AS carreta2
    ,redespacho.carreta3 AS carreta3
    ,motorista.razaosocial AS motorista_razao,
    redespacho.dtemissao::DATE AS dtemi,
    NULL AS nropedido,
    'Normal' AS tipo
    ,NULL as chaveacessocte
    ,NULL::integer AS numerodocumentoorigem
    ,NULL::integer AS filialdocumentoorigem
    ,NULL::integer AS unidadedocumentoorigem
    ,'' AS notasfiscaisdocumentoorigem
    ,redespacho.serie
    ,redespacho.valortotalprestacao AS valorreceber
    ,NULL as serie
    ,redespacho.usuarioemissor
    ,usuario_emissor.nomecompleto AS nomecompletoemissor
    ,NULL::integer AS kmfrete
    ,NULL::INT AS diferenciadornumero
    ,NULL::INT AS sequencia
    ,coleta.numero as coleta
    ,redespacho.trajeto AS trajeto
    ,trajeto.descricao AS trajeto_descricao
    ,veiculo.tipoveiculo
    ,veiculo.numerofrota
    ,redespacho.numero::VARCHAR AS numero_exibir

FROM redespacho

LEFT JOIN redespacho_comissao ON redespacho_comissao.grupo = redespacho.grupo
AND redespacho_comissao.empresa = redespacho.empresa
AND redespacho_comissao.cnpjcpfcodigoemissor = redespacho.cnpjcpfcodigoemissor
AND redespacho_comissao.dtemissao = redespacho.dtemissao
AND redespacho_comissao.serie = redespacho.serie
AND redespacho_comissao.numero = redespacho.numero

LEFT JOIN cadastro vendedor ON vendedor.codigo = redespacho_comissao.cnpjcpfcodigovendedor

LEFT JOIN cadastro motorista
    ON motorista.codigo = redespacho.motorista

LEFT JOIN usuario usuario_emissor
        ON usuario_emissor.codigo = redespacho.usuarioemissor

JOIN grupo ON redespacho.grupo=grupo.codigo

JOIN empresa ON redespacho.grupo=empresa.grupo AND redespacho.empresa=empresa.codigo

LEFT OUTER JOIN filial ON redespacho.grupo=filial.grupo
                                     AND redespacho.empresa=filial.empresa
                                     AND redespacho.filial=filial.codigo

LEFT OUTER JOIN unidade ON redespacho.grupo=unidade.grupo
                           AND redespacho.empresa=unidade.empresa
                  AND redespacho.filial=unidade.filial
                  AND redespacho.unidade=unidade.codigo

LEFT OUTER JOIN cadastro ON redespacho.remetente=cadastro.codigo

LEFT OUTER JOIN cadastro cadastro_1 ON redespacho.destinatario=cadastro_1.codigo

LEFT OUTER JOIN cadastro cadastro_2 ON redespacho.consignatario=cadastro_2.codigo

LEFT JOIN veiculo
    ON veiculo.placa = redespacho.veiculo

JOIN cadastro pagadorfrete ON pagadorfrete.codigo = redespacho.cnpjcpfcodigopagadorfrete

LEFT OUTER JOIN tipofrete
ON  tipofrete.grupo  = redespacho.grupo
AND tipofrete.empresa  = redespacho.empresa
AND tipofrete.codigo = redespacho.tipofrete


LEFT JOIN filial filialdestino ON filialdestino.grupo = 1
                              AND filialdestino.empresa = 1
                              AND filialdestino.codigo = COALESCE(0,0)


LEFT JOIN unidade unidadedestino ON unidadedestino.grupo = 1
                              AND unidadedestino.empresa = 1
                              AND unidadedestino.filial = COALESCE(0,0)
                              AND unidadedestino.codigo = COALESCE(0,0)




LEFT JOIN tipofrete tipofretecapa ON tipofretecapa.codigo = COALESCE(0,0)

LEFT OUTER JOIN redespacho_notafiscal ON redespacho.grupo = redespacho_notafiscal.grupo
                                             AND redespacho.empresa = redespacho_notafiscal.empresa
                                             AND redespacho.cnpjcpfcodigoemissor = redespacho_notafiscal.cnpjcpfcodigoemissor
                                             AND redespacho.dtemissao = redespacho_notafiscal.dtemissao
                                             AND redespacho.serie = redespacho_notafiscal.serie
                                             AND redespacho.numero = redespacho_notafiscal.numero

LEFT OUTER JOIN redespacho_notafiscal_item ON redespacho.grupo = redespacho_notafiscal_item.grupo
                                             AND redespacho.empresa = redespacho_notafiscal_item.empresa
                                             AND redespacho.cnpjcpfcodigoemissor = redespacho_notafiscal_item.cnpjcpfcodigoemissor
                                             AND redespacho.dtemissao = redespacho_notafiscal_item.dtemissao
                                             AND redespacho.serie = redespacho_notafiscal_item.serie
                                             AND redespacho.numero = redespacho_notafiscal_item.numero
                                             AND redespacho_notafiscal.numeronotafiscal = redespacho_notafiscal_item.numeronotafiscal

LEFT JOIN redespacho_endereco ON redespacho_endereco.grupo = redespacho.grupo
                            AND redespacho_endereco.empresa = redespacho.empresa
                            AND redespacho_endereco.cnpjcpfcodigoemissor = redespacho.cnpjcpfcodigoemissor
                            AND redespacho_endereco.dtemissao = redespacho.dtemissao
                            AND redespacho_endereco.serie = redespacho.serie
                            AND redespacho_endereco.numero = redespacho.numero
                            AND redespacho_endereco.tipo = 2

LEFT JOIN naturezamercadoria
ON naturezamercadoria.grupo = redespacho.grupo
AND naturezamercadoria.empresa = redespacho.empresa
AND naturezamercadoria.descricao = redespacho_notafiscal.naturezamercadoria

LEFT JOIN coleta
    ON coleta.grupo = redespacho.grupo
    AND coleta.empresa = redespacho.empresa
    AND coleta.filial = redespacho.filial
    AND coleta.unidade = redespacho.unidade
    AND coleta.serie = redespacho.serie
    AND coleta.numero = redespacho.numero

LEFT JOIN trajeto
    ON  trajeto.grupo = redespacho.grupo
    AND trajeto.empresa = redespacho.empresa
    AND trajeto.codigo = redespacho.trajeto


WHERE redespacho.grupo = 1
AND redespacho.empresa = 1
AND (COALESCE(1,0) = 0 OR redespacho.filial = 1)
AND (COALESCE(1,0) = 0 OR redespacho.unidade = 1)
AND (COALESCE(0,0) = 0 OR redespacho.filialdestino = 0)
AND (COALESCE(0,0)= 0 OR redespacho.unidadedestino = 0)
AND (redespacho.dtemissao BETWEEN ('{initialDate}'||' '||'00:00:00')::timestamp AND ('{finalDate}'||' '||'23:59:00')::timestamp)
AND (CASE WHEN 'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' <>'' THEN
        CASE WHEN 'Sim' = 'Sim' THEN
           (SUBSTR(redespacho.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(redespacho.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(redespacho.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8))
        ELSE
           (redespacho.remetente = FNC_DESFORMATA_CAMPO('') OR
            redespacho.destinatario = FNC_DESFORMATA_CAMPO('') OR
            redespacho.consignatario = FNC_DESFORMATA_CAMPO(''))
        END
     ELSE
        (CASE WHEN  'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' = '' THEN
            TRUE
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Remetente' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(redespacho.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               redespacho.remetente = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Destinatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(redespacho.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               redespacho.destinatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Consignatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(redespacho.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               redespacho.consignatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Pagador do Frete' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(redespacho.cnpjcpfcodigopagadorfrete,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               redespacho.cnpjcpfcodigopagadorfrete = FNC_DESFORMATA_CAMPO('')
            END
         END)
     END)
AND (COALESCE(0,0) = 0 OR redespacho.tipofrete = 0)
AND ('' = '' OR redespacho_notafiscal_item.produtocliente = '')
AND ('Todos' = 'Todos' OR 'Todos' = 'Redespacho')
AND ('' = '' OR redespacho.veiculo = UPPER(''))
AND (CASE WHEN 'Todos' = 'Todos' THEN
            TRUE
           WHEN 'Todos' = 'CIF' THEN
             redespacho.pagadorfrete = 1
           WHEN 'Todos' = 'FOB' THEN
            redespacho.pagadorfrete > 1
     END)

AND ('' = '' OR redespacho.motorista = FNC_DESFORMATA_CAMPO(''))


AND CASE WHEN COALESCE('','') = '' THEN TRUE ELSE redespacho_notafiscal.naturezamercadoria = '' END
AND CASE
        WHEN 'Todos' = 'Todos' THEN TRUE
        WHEN 'Todos' = 'Sim' THEN naturezamercadoria.quimico = 1
        WHEN 'Todos' = 'Não' THEN naturezamercadoria.quimico = 2
        END
AND COALESCE('','') = ''
AND CASE WHEN 'Todas' = 'Própria' THEN
            COALESCE(redespacho.tipofrota,veiculo.tipofrota) = 1
     WHEN 'Todas' = 'Terceiro' THEN
            COALESCE(redespacho.tipofrota,veiculo.tipofrota) = 2
     WHEN 'Todas' = 'Agregado' THEN
            COALESCE(redespacho.tipofrota,veiculo.tipofrota) = 3
     ELSE
         TRUE
     END


GROUP BY
1,2,3,4,5,6,7,8,9,10,
11,12,13,14,15,16,17,18,19,20,
21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,43,44,45,47,48,49,50,51,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78

UNION ALL

SELECT  -- N F   S E R V I Ç O
    '' AS leg_sac,
    CASE COALESCE(notafiscalservico_calculofrete.tipofrota, veiculo.tipofrota)
        WHEN 1 THEN
            ' Própria'
        WHEN 2 THEN
            ' Terceiro'
        WHEN 3 THEN
            ' Agregado'
    END AS tipofrota,
    'NFS-e'::VARCHAR AS tipodocumento,

    notafiscalservico.grupo,
    grupo.nome AS nomegrupo,
    notafiscalservico.empresa,
    empresa.nome AS nomeempresa,
    notafiscalservico.filial,
    filial.apelido AS apelidofilial,
    notafiscalservico.unidade,
    unidade.descricao AS unidadedescricao,
    notafiscalservico_calculofrete.tipofrete,
    tipofrete.descricao AS tipofretedescricao,
    notafiscalservico_calculofrete.tipocarga,
    tipocarga.descricao AS tipocargadescricao,
    notafiscalservico.numero::VARCHAR AS numero,
    notafiscalservico.dtemissao,
    COALESCE(notafiscalservico_calculofrete.dtprevisaoentrega, coleta.dtprevisaochegadaviagem) AS dtprevisaoentrega,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(notafiscalservico_calculofrete.remetente),'') AS cpfcnpjremetente,
    remetente.razaosocial AS razaoremetente,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(notafiscalservico_calculofrete.destinatario),'') AS cpfcnpjdestinatario,
    destinatario.razaosocial AS razaodestinatario,
    COALESCE(notafiscalservico_calculofrete.consignatario,'') AS consignatario,
    consignatario.razaosocial AS razaoconsignatario,
    notafiscalservico_calculofrete.cidadecoleta,
    notafiscalservico_calculofrete.ufcoleta,
    notafiscalservico_calculofrete.cidadeentrega,
    notafiscalservico_calculofrete.ufentrega,
    notafiscalservico_calculofrete.veiculo,
    COALESCE(notafiscalservico_calculofrete.quantidade,0) AS quantidade,
    COALESCE(notafiscalservico_calculofrete.m3,0) AS m3,
    COALESCE(notafiscalservico_calculofrete.peso,0) AS peso,
    0::NUMERIC AS valoricms,
    COALESCE(notafiscalservico.valoriss,0) + COALESCE(notafiscalservico.valorissretido,0) + COALESCE(notafiscalservico.valorissdevidomunicipioincidenciaimposto,0) AS valoriss,
    COALESCE(notafiscalservico_calculofrete.valortotalmercadoria,0) AS valortotalmercadoria,
    COALESCE(NULLIF(notafiscalservico_calculofrete.valortotalfrete,0),notafiscalservico.valortotalbruto) AS valortotalprestacao,
    (COALESCE(NULLIF(notafiscalservico_calculofrete.valortotalfrete,0),notafiscalservico.valortotalliquido) - COALESCE(notafiscalservico_calculofrete.valortaxapedagio,0)) AS valor_liquido,
    CASE WHEN notafiscalservico_calculofrete.remetente = notafiscalservico.cnpjcpfcodigo THEN 'CIF' ELSE 'FOB' END AS pagadorfrete,
    notafiscalservico.dtcancelamento,
    fnc_busca_notas_documentos(notafiscalservico.grupo,
                                                      notafiscalservico.empresa,
                                                      notafiscalservico.filial,
                                                      notafiscalservico.unidade,
                                                      notafiscalservico.diferenciadornumero,
                                                      notafiscalservico.serie,
                                                      notafiscalservico.numero,
                                                      null,
                                                      null,
                                                      notafiscalservico.tipodocumento) AS notas,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT notafiscalservico_item.descricao),', ')   AS produto,
    filialdestino.apelido AS nomefilialdestino,
    unidadedestino.descricao AS nomeunidadedestino,
    ''::VARCHAR AS tipofretemodalcapa,
    0::NUMERIC AS pesoaferido,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT vendedor.razaosocial),', ')   AS vendedor,
    pagadorfrete.razaosocial AS razaosocial_pagadorfrete
    ,notafiscalservico_calculofrete.valortaxapedagio
    ,COALESCE(notafiscalservico_calculofrete.peso,0) AS pesoliquido
    ,notafiscalservico_endereco.endereco || ' nº ' || notafiscalservico_endereco.numeroendereco AS enderecodestinatario
    ,notafiscalservico_endereco.complemento
    ,1::INT AS permitesac
    ,10::INT AS tipodocumentocod
    ,notafiscalservico_calculofrete.carreta1 AS carreta1
    ,notafiscalservico_calculofrete.carreta2 AS carreta2
    ,notafiscalservico_calculofrete.carreta3 AS carreta3
    ,motorista.razaosocial AS motorista_razao
    ,notafiscalservico.dtemissao::DATE AS dtemi
    ,coleta.numerofatura AS nropedido,
    'Normal' AS tipo
    ,NULL as chaveacessocte
    ,NULL::integer AS numerodocumentoorigem
    ,NULL::integer AS filialdocumentoorigem
    ,NULL::integer AS unidadedocumentoorigem
    ,'' AS notasfiscaisdocumentoorigem
    ,notafiscalservico.serie
    ,notafiscalservico.valortotalliquido AS valorreceber
    ,NULL as serie
    ,notafiscalservico.usuarioemissor
    ,usuario_emissor.nomecompleto AS nomecompletoemissor
    ,trajeto.extensao AS kmfrete
    ,notafiscalservico.diferenciadornumero AS diferenciadornumero
    ,NULL::INT AS sequencia
    ,coleta.numero as coleta
    ,coleta.trajeto AS trajeto
    ,trajeto.descricao AS trajetodescricao
    ,veiculo.tipoveiculo
    ,veiculo.numerofrota
    ,COALESCE(notafiscalservico.numeronfse::VARCHAR ,notafiscalservico.numero::VARCHAR )AS numero_exibir
FROM notafiscalservico

LEFT JOIN notafiscalservico_calculofrete
ON notafiscalservico_calculofrete.grupo = notafiscalservico.grupo
AND notafiscalservico_calculofrete.empresa = notafiscalservico.empresa
AND notafiscalservico_calculofrete.filial = notafiscalservico.filial
AND notafiscalservico_calculofrete.unidade = notafiscalservico.unidade
AND notafiscalservico_calculofrete.diferenciadornumero = notafiscalservico.diferenciadornumero
AND notafiscalservico_calculofrete.serie = notafiscalservico.serie
AND notafiscalservico_calculofrete.numero = notafiscalservico.numero


LEFT JOIN notafiscalservico_comissao ON notafiscalservico_comissao.grupo = notafiscalservico.grupo
AND notafiscalservico_comissao.empresa = notafiscalservico.empresa
AND notafiscalservico_comissao.filial = notafiscalservico.filial
AND notafiscalservico_comissao.unidade = notafiscalservico.unidade
AND notafiscalservico_comissao.diferenciadornumero = notafiscalservico.diferenciadornumero
AND notafiscalservico_comissao.serie = notafiscalservico.serie
AND notafiscalservico_comissao.numero = notafiscalservico.numero

LEFT JOIN notafiscalservico_composicao
    ON notafiscalservico_composicao.grupo = notafiscalservico.grupo
    AND notafiscalservico_composicao.empresa = notafiscalservico.empresa
    AND notafiscalservico_composicao.filial = notafiscalservico.filial
    AND notafiscalservico_composicao.unidade = notafiscalservico.unidade
    AND notafiscalservico_composicao.diferenciadornumero = notafiscalservico.diferenciadornumero
    AND notafiscalservico_composicao.serie = notafiscalservico.serie
    AND notafiscalservico_composicao.numero = notafiscalservico.numero

LEFT JOIN cadastro vendedor ON vendedor.codigo = notafiscalservico_comissao.cnpjcpfcodigovendedor

LEFT JOIN usuario usuario_emissor
    ON usuario_emissor.codigo = notafiscalservico.usuarioemissor

LEFT JOIN cadastro motorista
    ON motorista.codigo = notafiscalservico_calculofrete.motorista

LEFT JOIN veiculo
    ON veiculo.placa = notafiscalservico_calculofrete.veiculo

JOIN grupo ON notafiscalservico.grupo = grupo.codigo

JOIN empresa ON notafiscalservico.grupo = empresa.grupo AND notafiscalservico.empresa = empresa.codigo

LEFT OUTER JOIN filial ON notafiscalservico.grupo = filial.grupo
                       AND notafiscalservico.empresa = filial.empresa
                       AND notafiscalservico.filial = filial.codigo

LEFT OUTER JOIN unidade ON notafiscalservico.grupo = unidade.grupo
                        AND notafiscalservico.empresa = unidade.empresa
                        AND notafiscalservico.filial = unidade.filial
                        AND notafiscalservico.unidade = unidade.codigo


LEFT JOIN filial filialdestino ON filialdestino.grupo = 1
                              AND filialdestino.empresa = 1
                              AND filialdestino.codigo = COALESCE(0,0)


LEFT JOIN unidade unidadedestino ON unidadedestino.grupo = 1
                              AND unidadedestino.empresa = 1
                              AND unidadedestino.filial = COALESCE(0,0)
                              AND unidadedestino.codigo = COALESCE(0,0)

LEFT OUTER JOIN tipofrete
ON  tipofrete.grupo  = notafiscalservico_calculofrete.grupo
AND tipofrete.empresa  = notafiscalservico_calculofrete.empresa
AND tipofrete.codigo = notafiscalservico_calculofrete.tipofrete

LEFT OUTER JOIN tipocarga
ON  tipocarga.grupo  = notafiscalservico_calculofrete.grupo
AND tipocarga.empresa  = notafiscalservico_calculofrete.empresa
AND tipocarga.codigo = notafiscalservico_calculofrete.tipocarga



LEFT OUTER JOIN cadastro remetente ON remetente.codigo = COALESCE(notafiscalservico_calculofrete.remetente,notafiscalservico.cnpjcpfcodigo)
LEFT OUTER JOIN cadastro destinatario ON destinatario.codigo = notafiscalservico_calculofrete.destinatario
LEFT OUTER JOIN cadastro consignatario ON consignatario.codigo = notafiscalservico_calculofrete.consignatario
LEFT JOIN cadastro pagadorfrete ON pagadorfrete.codigo = notafiscalservico.cnpjcpfcodigo
LEFT OUTER JOIN tipodocumento ON tipodocumento.codigo = notafiscalservico.tipodocumento


LEFT OUTER JOIN notafiscalservico_item ON notafiscalservico.grupo = notafiscalservico_item.grupo
                                             AND notafiscalservico.empresa = notafiscalservico_item.empresa
                                             AND notafiscalservico.filial = notafiscalservico_item.filial
                                             AND notafiscalservico.unidade = notafiscalservico_item.unidade
                                             AND notafiscalservico.diferenciadornumero = notafiscalservico_item.diferenciadornumero
                                             AND notafiscalservico.serie = notafiscalservico_item.serie
                                             AND notafiscalservico.numero = notafiscalservico_item.numero


LEFT OUTER JOIN notafiscalservico_notafiscal ON notafiscalservico_notafiscal.grupo = notafiscalservico_item.grupo
                                             AND notafiscalservico_notafiscal.empresa = notafiscalservico_item.empresa
                                             AND notafiscalservico_notafiscal.filial = notafiscalservico_item.filial
                                             AND notafiscalservico_notafiscal.unidade = notafiscalservico_item.unidade
                                             AND notafiscalservico_notafiscal.diferenciadornumero = notafiscalservico_item.diferenciadornumero
                                             AND notafiscalservico_notafiscal.serie = notafiscalservico_item.serie
                                             AND notafiscalservico_notafiscal.numero = notafiscalservico_item.numero


LEFT OUTER JOIN notafiscalservico_notafiscal_item ON notafiscalservico_notafiscal_item.grupo = notafiscalservico_notafiscal.grupo
                                             AND notafiscalservico_notafiscal_item.empresa = notafiscalservico_notafiscal.empresa
                                             AND notafiscalservico_notafiscal_item.filial = notafiscalservico_notafiscal.filial
                                             AND notafiscalservico_notafiscal_item.unidade = notafiscalservico_notafiscal.unidade
                                             AND notafiscalservico_notafiscal_item.diferenciadornumero = notafiscalservico_notafiscal.diferenciadornumero
                                             AND notafiscalservico_notafiscal_item.serie = notafiscalservico_notafiscal.serie
                                             AND notafiscalservico_notafiscal_item.numero = notafiscalservico_notafiscal.numero
                                              AND notafiscalservico_notafiscal_item.numeronotafiscal = notafiscalservico_notafiscal.numeronotafiscal

LEFT JOIN notafiscalservico_endereco ON notafiscalservico_endereco.grupo = notafiscalservico.grupo
                                        AND notafiscalservico_endereco.empresa = notafiscalservico.empresa
                                        AND notafiscalservico_endereco.filial = notafiscalservico.filial
                                        AND notafiscalservico_endereco.unidade = notafiscalservico.unidade
                                        AND notafiscalservico_endereco.diferenciadornumero = notafiscalservico.diferenciadornumero
                                        AND notafiscalservico_endereco.serie = notafiscalservico.serie
                                        AND notafiscalservico_endereco.numero = notafiscalservico.numero
                                        AND notafiscalservico_endereco.tipo = 2

LEFT JOIN naturezamercadoria
ON naturezamercadoria.grupo = notafiscalservico.grupo
AND naturezamercadoria.empresa = notafiscalservico.empresa
AND naturezamercadoria.descricao = notafiscalservico_notafiscal.naturezamercadoria

LEFT JOIN coleta
    ON coleta.grupo = notafiscalservico_composicao.grupo
    AND coleta.empresa = notafiscalservico_composicao.empresa
    AND coleta.filial = notafiscalservico_composicao.filialdocumento
    AND coleta.unidade = notafiscalservico_composicao.unidadedocumento
    AND coleta.diferenciadornumero = notafiscalservico_composicao.diferenciadornumerodocumento
    AND coleta.serie = notafiscalservico_composicao.seriedocumento
    AND coleta.numero = notafiscalservico_composicao.numerodocumento
    AND coleta.tipodocumento = notafiscalservico_composicao.tipodocumento

LEFT JOIN trajeto
    ON  trajeto.grupo = coleta.grupo
    AND trajeto.empresa = coleta.empresa
    AND trajeto.codigo = coleta.trajeto


WHERE notafiscalservico.grupo = 1
AND notafiscalservico.empresa = 1
AND (COALESCE(1,0) = 0 OR notafiscalservico.filial = 1)
AND (COALESCE(1,0) = 0 OR notafiscalservico.unidade = 1)
AND notafiscalservico.numero<1000000
AND (notafiscalservico.dtemissao BETWEEN ('{initialDate}'||' '||'00:00:00')::timestamp AND ('{finalDate}'||' '||'23:59:00')::timestamp)
AND notafiscalservico.dtcancelamento IS NULL
AND (CASE WHEN 'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' <>'' THEN
        CASE WHEN 'Sim' = 'Sim' THEN
           (SUBSTR(notafiscalservico_calculofrete.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(notafiscalservico_calculofrete.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(notafiscalservico_calculofrete.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8))
        ELSE
           (notafiscalservico_calculofrete.remetente = FNC_DESFORMATA_CAMPO('') OR
            notafiscalservico_calculofrete.destinatario = FNC_DESFORMATA_CAMPO('') OR
            notafiscalservico_calculofrete.consignatario = FNC_DESFORMATA_CAMPO(''))
        END
     ELSE
        (CASE WHEN  'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' = '' THEN
            TRUE
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Remetente' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(notafiscalservico_calculofrete.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               notafiscalservico_calculofrete.remetente = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Destinatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(notafiscalservico_calculofrete.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               notafiscalservico_calculofrete.destinatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Consignatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(notafiscalservico_calculofrete.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               notafiscalservico_calculofrete.consignatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Pagador do Frete' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(notafiscalservico.cnpjcpfcodigo,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               notafiscalservico.cnpjcpfcodigo = FNC_DESFORMATA_CAMPO('')
            END
         END)
     END)
AND (COALESCE(0,0) = 0 OR notafiscalservico_calculofrete.tipofrete = 0)
AND (COALESCE(0,0) = 0 OR notafiscalservico_calculofrete.tipocarga = 0)

AND ('' = '' OR notafiscalservico_notafiscal_item.produtocliente = '')
AND (notafiscalservico.emissaoeletronica = 2 OR (notafiscalservico.emissaoeletronica = 1 AND notafiscalservico.situacaonfse = 3))
AND ('Todos' = 'Todos' OR 'Todos' = 'NFS-e')
AND ('' = '' OR notafiscalservico_calculofrete.veiculo = UPPER(''))

AND (CASE WHEN 'Todos' = 'Todos' THEN
        TRUE
       WHEN 'Todos' = 'CIF' THEN
         notafiscalservico_calculofrete.remetente = notafiscalservico.cnpjcpfcodigo
       WHEN 'Todos' = 'FOB' THEN
        notafiscalservico_calculofrete.remetente <> notafiscalservico.cnpjcpfcodigo
 END)

AND ('' = '' OR notafiscalservico_calculofrete.motorista = FNC_DESFORMATA_CAMPO(''))
AND CASE WHEN COALESCE('','') = '' THEN TRUE ELSE notafiscalservico_notafiscal.naturezamercadoria = '' END
AND CASE
        WHEN 'Todos' = 'Todos' THEN TRUE
        WHEN 'Todos' = 'Sim' THEN naturezamercadoria.quimico = 1
        WHEN 'Todos' = 'Não' THEN naturezamercadoria.quimico = 2
        END
AND COALESCE('','') = ''
AND CASE WHEN 'Todas' = 'Própria' THEN
            COALESCE(notafiscalservico_calculofrete.tipofrota,veiculo.tipofrota) = 1
     WHEN 'Todas' = 'Terceiro' THEN
           COALESCE(notafiscalservico_calculofrete.tipofrota,veiculo.tipofrota) = 2
     WHEN 'Todas' = 'Agregado' THEN
           COALESCE(notafiscalservico_calculofrete.tipofrota,veiculo.tipofrota) = 3
     ELSE
         TRUE
     END


GROUP BY
1,2,3,4,5,6,7,8,9,10,
11,12,13,14,15,16,17,18,19,20,
21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,43,44,45,47,48,49,50,51,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79


UNION ALL
---------------------------------------------------------------    CRT   CRT   CRT   CRT  CRT  -------------------------------------------

SELECT
    '' AS leg_sac,
    CASE COALESCE(crt.tipofrota, veiculo.tipofrota)
        WHEN 1 THEN
            ' Própria'
        WHEN 2 THEN
            ' Terceiro'
        WHEN 3 THEN
            ' Agregado'
    END AS tipofrota,
   'CRT'::VARCHAR AS tipodocumento,

   crt.grupo,
   grupo.nome AS nomegrupo,
   crt.empresa,
   empresa.nome AS nomeempresa,
    crt.filial,
    filial.apelido AS apelidofilial,
    crt.unidade,
    unidade.descricao AS unidadedescricao,
    crt.tipofrete,
    tipofrete.descricao AS tipofretedescricao,
    crt.tipocarga,
    tipocarga.descricao AS tipocargadescricao,
    crt.numero,
    crt.dtemissao,
    crt.dtprevisaoentrega,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(crt.remetente),'') AS cpfcnpjremetente,
    remetente.razaosocial AS razaoremetente,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(crt.destinatario),'') AS cpfcnpjdestinatario,
    destinatario.razaosocial AS razaodestinatario,
    crt.consignatario,
    consignatario.razaosocial AS razaoconsignatario,
    crt.cidadecoleta,
    crt.ufcoleta,
    crt.cidadeentrega,
    crt.ufentrega,
    crt.veiculo,
    COALESCE(crt.quantidade,0) AS quantidade,
    COALESCE(crt.m3,0) AS m3,
    COALESCE(crt.pesobruto,0) AS peso,
    0::NUMERIC(15,2) AS valoricms,
    0::NUMERIC(15,2) AS valoriss,
    COALESCE(crt.dadosvalor,0) * COALESCE(crt.valorcambiovalormercadoria,0) AS valortotalmercadoria,
    crt.valormoedacorrenteemissao AS valortotalprestacao,
    (COALESCE(crt.valormoedacorrenteemissao,0) - COALESCE(crt.valortaxapedagio,0)) AS valor_liquido,
    CASE WHEN crt.pagadorfrete = 1 THEN 'CIF' ELSE 'FOB' END AS pagadorfrete,
    crt.dtcancelamento,


   fnc_busca_notas_documentos(crt.grupo,
                             crt.empresa,
                             crt.filial,
                             crt.unidade,
                             crt.diferenciadorsequencia,
                             null,
                             crt.sequencia,
                             null,
                             null,
                             13) AS notas,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT crt_notafiscal_item.produtodescricao),', ')   AS produto,

    filialdestino.apelido AS nomefilialdestino,
    unidadedestino.descricao AS nomeunidadedestino,
    tipofretecapa.descricao AS tipofretemodalcapa,
    0::numeric AS pesoaferido,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT vendedor.razaosocial),', ')   AS vendedor,
    CASE WHEN crt.pagadorfrete = 1 THEN
            pagadorfrete_remetente.razaosocial
         WHEN crt.pagadorfrete = 2 THEN
            pagadorfrete_destinatario.razaosocial
         WHEN crt.pagadorfrete = 3 THEN
            pagadorfrete_consignatario.razaosocial
         WHEN crt.pagadorfrete = 4 THEN
            (pagadorfrete_remetente.razaosocial||'-'||pagadorfrete_destinatario.razaosocial)
         WHEN crt.pagadorfrete = 5 THEN
            (pagadorfrete_remetente.razaosocial||'-'||pagadorfrete_consignatario.razaosocial)
         WHEN crt.pagadorfrete = 6 THEN
            (pagadorfrete_destinatario.razaosocial||'-'||pagadorfrete_consignatario.razaosocial)
         WHEN crt.pagadorfrete = 7 THEN
            (pagadorfrete_remetente.razaosocial||'-'||pagadorfrete_destinatario.razaosocial||'-'||pagadorfrete_consignatario.razaosocial)
    END AS razaosocial_pagadorfrete
    ,crt.valortaxapedagio
    ,COALESCE(crt.pesoliquido,0) AS pesoliquido
    ,(SELECT endereco || ' nº ' || numero FROM cadastro WHERE codigo = crt.destinatario) AS enderecodestinatario
    ,(SELECT complemento FROM cadastro WHERE codigo = crt.destinatario)AS complemento
    ,1::INT AS permitesac
    ,13::INT AS tipodocumentocod
    ,crt.carreta1 AS carreta1
    ,crt.carreta2 AS carreta2
    ,crt.carreta3 AS carreta3
    ,motorista.razaosocial AS motorista_razao
    ,crt.dtemissao::DATE AS dtemi
    ,NULL AS nropedido,
    'Normal' AS tipo
    ,NULL as chaveacessocte
    ,NULL::integer AS numerodocumentoorigem
    ,NULL::integer AS filialdocumentoorigem
    ,NULL::integer AS unidadedocumentoorigem
    ,'' AS notasfiscaisdocumentoorigem
    , null::INTEGER AS serie
    ,crt.valortotalprestacao AS valorreceber
    ,NULL as serie
    ,crt.usuarioemissor
    ,usuario_emissor.nomecompleto AS nomecompletoemissor
    ,NULL::integer AS kmfrete
    ,crt.diferenciadorsequencia AS diferenciadornumero
    ,crt.sequencia AS sequencia
    ,coleta.numero as coleta
    ,crt.trajeto AS trajeto
    ,trajeto.descricao AS trajetodescricao
    ,veiculo.tipoveiculo
    ,veiculo.numerofrota
    ,crt.numero::VARCHAR AS numero_exibir

   FROM crt

    LEFT OUTER JOIN crt_notafiscal_item ON crt.grupo = crt_notafiscal_item.grupo
                                                 AND crt.empresa = crt_notafiscal_item.empresa
                                                 AND crt.filial = crt_notafiscal_item.filial
                                                 AND crt.unidade = crt_notafiscal_item.unidade
                                                 AND crt.diferenciadorsequencia = crt_notafiscal_item.diferenciadorsequencia
                                                   AND crt.sequencia = crt_notafiscal_item.sequencia

    LEFT JOIN crt_comissao ON crt_comissao.grupo = crt.grupo
    AND crt_comissao.empresa = crt.empresa
    AND crt_comissao.filial = crt.filial
    AND crt_comissao.unidade = crt.unidade
    AND crt_comissao.diferenciadorsequencia = crt.diferenciadorsequencia
    AND crt_comissao.sequencia = crt.sequencia

    LEFT JOIN cadastro vendedor ON vendedor.codigo = crt_comissao.cnpjcpfcodigovendedor

    LEFT JOIN cadastro motorista
        ON motorista.codigo = crt.motorista

    LEFT JOIN usuario usuario_emissor
        ON usuario_emissor.codigo = crt.usuarioemissor

   JOIN cadastro remetente
   ON remetente.codigo = crt.remetente

   JOIN cadastro destinatario
   ON destinatario.codigo = crt.destinatario

   LEFT JOIN cadastro consignatario
   ON consignatario.codigo = crt.consignatario

    LEFT JOIN veiculo
        ON veiculo.placa = crt.veiculo

   LEFT JOIN cadastro pagadorfrete_remetente
           ON pagadorfrete_remetente.codigo = (CASE WHEN crt.pagadorfrete = 1 THEN
                                                 crt.remetente end)

   LEFT JOIN cadastro pagadorfrete_destinatario
           ON pagadorfrete_destinatario.codigo = (CASE WHEN crt.pagadorfrete = 2 THEN
                                                 crt.destinatario end)

   LEFT JOIN cadastro pagadorfrete_consignatario
           ON pagadorfrete_consignatario.codigo = (CASE WHEN crt.pagadorfrete = 3 THEN
                                                 crt.consignatario end)

    LEFT OUTER JOIN tipofrete
    ON  tipofrete.grupo  = crt.grupo
    AND tipofrete.empresa  = crt.empresa
    AND tipofrete.codigo = crt.tipofrete

    LEFT OUTER JOIN tipocarga
    ON  tipocarga.grupo  = crt.grupo
    AND tipocarga.empresa  = crt.empresa
    AND tipocarga.codigo = crt.tipocarga


   JOIN grupo
   ON grupo.codigo = crt.grupo

   JOIN empresa
   ON  empresa.grupo = crt.grupo
   AND empresa.codigo = crt.empresa

   JOIN filial
   ON  filial.grupo   = crt.grupo
   AND filial.empresa = crt.empresa
   AND filial.codigo  = crt.filial

   JOIN unidade
   ON  unidade.grupo  = crt.grupo
   AND unidade.empresa = crt.empresa
   AND unidade.filial  = crt.filial
   AND unidade.codigo  = crt.unidade

    LEFT JOIN tipofrete tipofretecapa ON tipofretecapa.codigo = COALESCE(0,0)


    LEFT JOIN filial filialdestino ON filialdestino.grupo = 1
                                  AND filialdestino.empresa = 1
                                  AND filialdestino.codigo = COALESCE(0,0)


    LEFT JOIN unidade unidadedestino ON unidadedestino.grupo = 1
                                  AND unidadedestino.empresa = 1
                                  AND unidadedestino.filial = COALESCE(0,0)
                                  AND unidadedestino.codigo = COALESCE(0,0)

    LEFT JOIN naturezamercadoria
    ON naturezamercadoria.grupo = crt.grupo
    AND naturezamercadoria.empresa = crt.empresa
    AND naturezamercadoria.descricao = crt.naturezamercadoria


    LEFT JOIN coleta
    ON coleta.grupo = crt.grupo
    AND coleta.empresa = crt.empresa
    AND coleta.filial = crt.filial
    AND coleta.unidade = crt.unidade
    AND coleta.diferenciadornumero = crt.diferenciadorsequencia
    AND coleta.numero = crt.sequencia

    LEFT JOIN trajeto
    ON  trajeto.grupo = crt.grupo
    AND trajeto.empresa = crt.empresa
    AND trajeto.codigo = crt.trajeto



   WHERE crt.grupo   = 1
    AND crt.empresa = 1
    AND (COALESCE(1,0) = 0 OR crt.filial = COALESCE(1,0))
    AND (COALESCE(1,0) = 0 OR crt.unidade = COALESCE(1,0))
    AND (COALESCE(0,0) = 0 OR crt.filialdestino = 0)
    AND (COALESCE(0,0)= 0 OR crt.unidadedestino = 0)

    AND (crt.dtemissao BETWEEN ('{initialDate}'||' '||'00:00:00')::timestamp AND ('{finalDate}'||' '||'23:59:00')::timestamp)
    AND crt.sequencia < 1000000
    AND crt.dtcancelamento IS NULL
   AND ('' = '' OR crt.veiculo = UPPER(''))
    AND ('Todos' = 'Todos' OR 'Todos' = 'CRT')

    AND (CASE WHEN 'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' <>'' THEN
        CASE WHEN 'Sim' = 'Sim' THEN
           (SUBSTR(crt.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(crt.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8) OR
            SUBSTR(crt.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8))
        ELSE
           (crt.remetente = FNC_DESFORMATA_CAMPO('') OR
            crt.destinatario = FNC_DESFORMATA_CAMPO('') OR
            crt.consignatario = FNC_DESFORMATA_CAMPO(''))
        END
     ELSE
        (CASE WHEN  'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' = '' THEN
            TRUE
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Remetente' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(crt.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               crt.remetente = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Destinatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(crt.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               crt.destinatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Consignatário' THEN
            CASE WHEN 'Sim' = 'Sim' THEN
               SUBSTR(crt.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)
            ELSE
               crt.consignatario = FNC_DESFORMATA_CAMPO('')
            END
         WHEN '' <> '' AND 'Todos (Informar Cnpj/Cpf/Código)' = 'Pagador do Frete' THEN
            CASE WHEN 'Sim' = 'Sim' THEN

                ((crt.valorfretepagoremetente > 0 AND SUBSTR(crt.remetente,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)) OR
                (crt.valorfretepagodestinatario > 0 AND  SUBSTR(crt.destinatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)) OR
                 (crt.valorfretepagoconsignatario > 0 AND  SUBSTR(crt.consignatario,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8)))
            ELSE
                ((crt.valorfretepagoremetente > 0 AND crt.remetente = FNC_DESFORMATA_CAMPO('')) OR
                (crt.valorfretepagodestinatario > 0 AND  crt.destinatario = FNC_DESFORMATA_CAMPO('')) OR
                 (crt.valorfretepagoconsignatario > 0 AND  crt.consignatario = FNC_DESFORMATA_CAMPO('')))
            END
         END)
     END)
    AND (CASE WHEN 'Todos' = 'Todos' THEN
            TRUE
           WHEN 'Todos' = 'CIF' THEN
             crt.pagadorfrete = 1
           WHEN 'Todos' = 'FOB' THEN
            crt.pagadorfrete > 1
     END)
AND ('' = '' OR crt.motorista = FNC_DESFORMATA_CAMPO(''))


AND CASE WHEN COALESCE('','') = '' THEN TRUE ELSE crt.naturezamercadoria = '' END
AND CASE
        WHEN 'Todos' = 'Todos' THEN TRUE
        WHEN 'Todos' = 'Sim' THEN naturezamercadoria.quimico = 1
        WHEN 'Todos' = 'Não' THEN naturezamercadoria.quimico = 2
        END

--- PARA VERIFICAR SE TEM ALGUM CTE QUE SUBSTITUIR O CRT PARA NÃO DUPLICAR OS VALORES NO RELATÓRIO....
AND NOT EXISTS (SELECT NULL
                FROM   conhecimento_composicao

                JOIN conhecimento
                    ON conhecimento.grupo = conhecimento_composicao.grupo
                    AND conhecimento.empresa = conhecimento_composicao.empresa
                    AND conhecimento.filial = conhecimento_composicao.filial
                    AND conhecimento.unidade = conhecimento_composicao.unidade
                    AND conhecimento.diferenciadornumero = conhecimento_composicao.diferenciadornumero
                    AND conhecimento.serie = conhecimento_composicao.serie
                    AND conhecimento.numero = conhecimento_composicao.numero

                WHERE conhecimento_composicao.tipodocumento = crt.tipodocumento
                AND conhecimento_composicao.grupo = crt.grupo
                AND conhecimento_composicao.empresa = crt.empresa
                AND conhecimento_composicao.filialdocumento = crt.filial
                AND conhecimento_composicao.unidadedocumento = crt.unidade
                AND conhecimento_composicao.diferenciadornumerodocumento = crt.diferenciadorsequencia
                AND conhecimento_composicao.numerodocumento = crt.sequencia
                AND conhecimento.dtcancelamento IS NULL
                )
AND COALESCE('','') = ''
AND CASE WHEN 'Todas' = 'Própria' THEN
            COALESCE(crt.tipofrota,veiculo.tipofrota) = 1
     WHEN 'Todas' = 'Terceiro' THEN
            COALESCE(crt.tipofrota,veiculo.tipofrota) = 2
     WHEN 'Todas' = 'Agregado' THEN
            COALESCE(crt.tipofrota,veiculo.tipofrota) = 3
     ELSE
         TRUE
     END


GROUP BY
1,2,3,4,5,6,7,8,9,10,
11,12,13,14,15,16,17,18,19,20,
21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,43,44,45,47,48,49,50,51,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78


UNION ALL


SELECT
    '' AS leg_sac,
    ''::VARCHAR AS tipofrota,
    'NF-e Saída'::VARCHAR AS tipodocumento,

    notafiscalsaida.grupo,
    grupo.nome AS nomegrupo,
    notafiscalsaida.empresa,
    empresa.nome AS nomeempresa,
    notafiscalsaida.filial,
    filial.apelido AS apelidofilial,
    notafiscalsaida.unidade,
    unidade.descricao AS unidadedescricao,
    NULL::INTEGER AS tipofrete,
    ''::VARCHAR AS tipofretedescricao,
    NULL::INTEGER AS tipocarga,
    ''::VARCHAR AS tipocargadescricao,
    notafiscalsaida.numero::VARCHAR AS numero,
    notafiscalsaida.dtemissao,
    NULL::DATE AS dtprevisaoentrega,
    COALESCE(avacorpi.fnc_formata_cnpjcpf(notafiscalsaida.cnpjcpfcodigo),'') AS cpfcnpjremetente,
    cadastro.razaosocial AS razaoremetente,
    ''::VARCHAR AS cpfcnpjdestinatario,
    ''::VARCHAR AS razaodestinatario,
    ''::VARCHAR AS consignatario,
    ''::VARCHAR AS razaoconsignatario,
    ''::VARCHAR AS idadecoleta,
    ''::VARCHAR AS ufcoleta,
    ''::VARCHAR AS idadeentrega,
    ''::VARCHAR AS ufentrega,
    ''::VARCHAR AS veiculo,
    COALESCE(notafiscalsaida.quantidadetotalvolumes,0) AS quantidade,
    0::NUMERIC AS m3,
    COALESCE(notafiscalsaida.pesoliquido,0) AS peso,
    COALESCE(notafiscalsaida.valoricms,0) + COALESCE(notafiscalsaida.valoricmsretido,0) AS valoricms,
    COALESCE(notafiscalsaida.valoriss,0) AS valoriss,
    COALESCE(notafiscalsaida.valorprodutos,0) AS valortotalmercadoria,
    COALESCE(notafiscalsaida.valortotalnotafiscal,0) AS valortotalprestacao,
    (COALESCE(notafiscalsaida.valortotalnotafiscal,0)  - COALESCE(notafiscalsaida.valoricms,0) + COALESCE(notafiscalsaida.valoricmsretido,0)) AS valor_liquido,
    CASE WHEN notafiscalsaida.freteporconta = 1 THEN 'CIF' ELSE 'FOB' END AS pagadorfrete,
    notafiscalsaida.dtcancelamento,
    ''::VARCHAR AS notas,
    ARRAY_TO_STRING(ARRAY_ADD(DISTINCT notafiscalsaida_item.descricaoproduto),', ')   AS produto,
    ''::VARCHAR AS nomefilialdestino,
    ''::VARCHAR AS nomeunidadedestino,
    ''::VARCHAR AS tipofretemodalcapa,
    0::NUMERIC AS pesoaferido,
    ''::VARCHAR   AS vendedor,
    ''::VARCHAR AS razaosocial_pagadorfrete
    ,0::numeric AS valortaxapedagio
    ,COALESCE(notafiscalsaida.pesoliquido,0) AS pesoliquido
    ,notafiscalsaida_endereco.endereco || ' nº ' || notafiscalsaida_endereco.numeroendereco AS enderecodestintario
    ,notafiscalsaida_endereco.complemento
    ,2::INT AS permitesac
    ,12::INT AS tipodocumentocod
    ,''::VARCHAR AS carreta1
    ,''::VARCHAR AS carreta2
    ,''::VARCHAR AS carreta3
    ,''::VARCHAR AS motorista_razao
    ,notafiscalsaida.dtemissao::DATE AS dtemi
    ,NULL AS nropedido,
    --'Normal' AS tipo
    CASE notafiscalsaida.tiponotafiscal
        WHEN 1 THEN
            'Normal'
        WHEN 2 THEN
            'Devolução'
        WHEN 3 THEN
            'Beneficiamento'
        WHEN 4 THEN
            'Complemento ICMS'
        WHEN 5 THEN
            'Complemento IPI'
        WHEN 6 THEN
            'Beneficiamento'
        WHEN 7 THEN
            'WMS Normal'
        WHEN 8 THEN
            'WMS EDI'
        WHEN 9 THEN
            'Transferência ICMS'
        WHEN 10 THEN
            'Complemento de Preço'
        WHEN 11 THEN
            'Estorno'
        ELSE
            ' '
    END AS tipo

    ,NULL as chaveacessocte
    ,NULL::integer AS numerodocumentoorigem
    ,NULL::integer AS filialdocumentoorigem
    ,NULL::integer AS unidadedocumentoorigem
    ,'' AS notasfiscaisdocumentoorigem
    ,notafiscalsaida.serie
    ,NULL::integer AS valorreceber
    ,NULL as serie
    ,notafiscalsaida.usuarioemissor
    ,usuario_emissor.nomecompleto AS nomecompletoemissor
    ,NULL::integer AS kmfrete
    ,NULL::INT AS diferenciadornumero
    ,NULL::INT AS sequencia
    ,coleta.numero as coleta
    ,NULL::INT AS trajeto
    ,NULL::VARCHAR AS trajeto_descricao
    ,NULL::VARCHAR AS tipoveiculo
    ,NULL::VARCHAR AS numerofrota
    ,notafiscalsaida.numero::VARCHAR AS numero_exibir
FROM notafiscalsaida

LEFT JOIN notafiscalsaida_composicao ON notafiscalsaida_composicao.grupo = notafiscalsaida.grupo
AND notafiscalsaida_composicao.empresa = notafiscalsaida.empresa
AND notafiscalsaida_composicao.filial = notafiscalsaida.filial
AND notafiscalsaida_composicao.unidade = notafiscalsaida.unidade
AND notafiscalsaida_composicao.cnpjcpfcodigoemissor = notafiscalsaida.cnpjcpfcodigoemissor
AND notafiscalsaida_composicao.diferenciadornumero = notafiscalsaida.diferenciadornumero
AND notafiscalsaida_composicao.serie = notafiscalsaida.serie
AND notafiscalsaida_composicao.numero = notafiscalsaida.numero

JOIN grupo ON notafiscalsaida.grupo=grupo.codigo

JOIN empresa ON notafiscalsaida.grupo=empresa.grupo AND notafiscalsaida.empresa=empresa.codigo

LEFT OUTER JOIN filial ON notafiscalsaida.grupo=filial.grupo
                                     AND notafiscalsaida.empresa=filial.empresa
                                     AND notafiscalsaida.filial=filial.codigo

LEFT OUTER JOIN unidade ON notafiscalsaida.grupo=unidade.grupo
                           AND notafiscalsaida.empresa=unidade.empresa
                  AND notafiscalsaida.filial=unidade.filial
                  AND notafiscalsaida.unidade=unidade.codigo

LEFT OUTER JOIN cadastro ON notafiscalsaida.cnpjcpfcodigo=cadastro.codigo

LEFT JOIN usuario usuario_emissor
        ON usuario_emissor.codigo = notafiscalsaida.usuarioemissor

LEFT OUTER JOIN notafiscalsaida_item ON notafiscalsaida.grupo = notafiscalsaida_item.grupo
                                             AND notafiscalsaida.empresa = notafiscalsaida_item.empresa
                                             AND notafiscalsaida.filial = notafiscalsaida_item.filial
                                             AND notafiscalsaida.unidade = notafiscalsaida_item.unidade
                                             AND notafiscalsaida.cnpjcpfcodigoemissor = notafiscalsaida_item.cnpjcpfcodigoemissor
                                             AND notafiscalsaida.diferenciadornumero = notafiscalsaida_item.diferenciadornumero
                                             AND notafiscalsaida.numero = notafiscalsaida_item.numero

LEFT JOIN notafiscalsaida_endereco ON notafiscalsaida_endereco.grupo = notafiscalsaida.grupo
                    AND notafiscalsaida_endereco.empresa = notafiscalsaida.empresa
                    AND notafiscalsaida_endereco.filial = notafiscalsaida.filial
                    AND notafiscalsaida_endereco.unidade = notafiscalsaida.unidade
                    AND notafiscalsaida_endereco.cnpjcpfcodigoemissor = notafiscalsaida.cnpjcpfcodigoemissor
                    AND notafiscalsaida_endereco.diferenciadornumero = notafiscalsaida.diferenciadornumero
                    AND notafiscalsaida_endereco.serie = notafiscalsaida.serie
                    AND notafiscalsaida_endereco.numero = notafiscalsaida.numero
                    AND notafiscalsaida_endereco.tipo = 2


LEFT JOIN coleta
    ON coleta.grupo = notafiscalsaida.grupo
    AND coleta.empresa = notafiscalsaida.empresa
    AND coleta.filial = notafiscalsaida.filial
    AND coleta.unidade = notafiscalsaida.unidade
    AND coleta.diferenciadornumero = notafiscalsaida.diferenciadornumero
    AND coleta.serie = notafiscalsaida.serie
    AND coleta.numero = notafiscalsaida.numero




WHERE notafiscalsaida.grupo = 1
AND notafiscalsaida.empresa = 1
AND (COALESCE(1,0) = 0 OR notafiscalsaida.filial = COALESCE(1,0))
AND (COALESCE(1,0) = 0 OR notafiscalsaida.unidade = COALESCE(1,0))
AND notafiscalsaida.numero<1000000
AND (notafiscalsaida.dtemissao BETWEEN ('{initialDate}'||' '||'00:00:00')::timestamp AND ('{finalDate}'||' '||'23:59:00')::timestamp)
AND notafiscalsaida.dtcancelamento IS NULL
AND ('' = '' OR notafiscalsaida.placa = UPPER(''))
AND (CASE WHEN 'Todos (Informar Cnpj/Cpf/Código)' = 'Todos (Informar Cnpj/Cpf/Código)' AND '' <>'' THEN
        CASE WHEN 'Sim' = 'Sim' THEN
           (SUBSTR(notafiscalsaida.cnpjcpfcodigo,1,8) = SUBSTR(FNC_DESFORMATA_CAMPO(''),1,8))
        ELSE
           (notafiscalsaida.cnpjcpfcodigo = FNC_DESFORMATA_CAMPO(''))
        END
     ELSE
        TRUE
     END)
AND ('' = '' OR notafiscalsaida_item.produto = '')
AND ('Todos' = 'Todos' OR 'Todos' = 'NF-e Saída')


    AND (CASE WHEN 'Todos' = 'Todos' THEN
            TRUE
           WHEN 'Todos' = 'CIF' THEN
             notafiscalsaida.freteporconta = 1
           WHEN 'Todos' = 'FOB' THEN
            notafiscalsaida.freteporconta > 1
     END)
AND ('' = '' OR notafiscalsaida.motorista = FNC_DESFORMATA_CAMPO(''))

AND COALESCE('','') = ''
AND 'Todos' IN ('Todos','Não')
AND COALESCE('','') = ''


GROUP BY
1,2,3,4,5,6,7,8,9,10,
11,12,13,14,15,16,17,18,19,20,
21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,43,44,45,47,48,49,50,51,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78

) AS retorno

ORDER BY retorno.dtemissao,  retorno.filial, retorno.unidade, retorno.numero
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
          , Sum(quantidade) "_Sum_quantidade"
          , Sum(valoricms) "_Sum_valoricms"
          , Sum(valor_liquido) "_Sum_valor_liquido"
          , Sum(valortaxapedagio) "_Sum_valortaxapedagio"
          , Sum(valorreceber) "_Sum_valorreceber"
          , Sum(m3) "_Sum_m3"
          , Sum(peso) "_Sum_peso"
          , Sum(pesoliquido) "_Sum_pesoliquido"
          , Sum(valortotalmercadoria) "_Sum_valortotalmercadoria"
       FROM q_filtered
   )
SELECT *
FROM q_filtered, q_totals
ORDER BY dtemi ASC