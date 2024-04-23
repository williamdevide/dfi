WITH
   q_target AS
   (
-- Comando SQL original - INICIO
-- Não foram colocados todos os filtros na descrição pois não couberam.
SELECT
    q_retorno.placa
    ,q_retorno.numerofrota
    ,q_retorno.gefu
    ,q_retorno.tipodocumento
    ,q_retorno.tipodoc
    ,q_retorno.dtentrada
    ,q_retorno.dtemissao
    ,q_retorno.diferenciadornumero
    ,q_retorno.serie
    ,q_retorno.numero
    ,q_retorno.numeroordemservico
    ,q_retorno.descricaodefeito
    ,q_retorno.complemento
    ,q_retorno.fornecedornome
    ,q_retorno.descricao
    ,q_retorno.codigoproduto
    ,q_retorno.grupoproduto
    ,q_retorno.subgrupoproduto
    ,q_retorno.quantidade
    ,q_retorno.valortotal
    ,q_retorno.basepara
    ,q_retorno.diasgarantia
    ,q_retorno.marcadorgarantia
    ,q_retorno.tipoveiculo
    ,q_retorno.km
    ,q_retorno.horimetro
    ,q_retorno.observacao
    ,q_retorno.sequencia
    ,q_retorno.descricaoobjetivoos
    ,q_retorno.valortotalmaoobra
    ,q_retorno.valortotalpecas
    ,q_retorno.diferencamarcador
    ,CASE WHEN q_retorno.diferencamarcador > 0 THEN
            ROUND((q_retorno.valortotal / q_retorno.diferencamarcador),2)
          ELSE
            0
     END AS valor_gasto_km_rodado



FROM (------------------------BUSCA OS ITENS DE RATEIO DA NOTA FISCAL DE ENTRADA------------------------------
      SELECT
          DISTINCT
          COALESCE(notafiscalentrada_item_rateioveiculo.veiculo,ordemservico.veiculo) AS placa
          ,veiculo.numerofrota
          ,notafiscalentrada.grupo ||
           '-' || notafiscalentrada.empresa ||
           '-' || notafiscalentrada.filial ||
           '-' || notafiscalentrada.unidade AS gefu
          ,'NF Entrada Rateio'::VARCHAR AS tipodocumento
          ,'NF Entrada Rateio'::VARCHAR AS tipodoc
          ,notafiscalentrada.dtentrada::DATE AS dtentrada
          ,notafiscalentrada.dtemissao::DATE AS dtemissao
          ,0::INTEGER AS diferenciadornumero
          ,notafiscalentrada.serie AS serie
          ,notafiscalentrada.numero
          ,Notafiscalentrada_item_rateioveiculo.numeroordemservico
          ,STRING_AGG(defeito.codigo::VARCHAR || '-' || defeito.descricao::VARCHAR
              ,','
               ORDER BY defeito.codigo) AS descricaodefeito
          ,STRING_AGG(ordemservico_defeito.complemento::VARCHAR ,',') AS complemento
          ,fornecedor.razaosocial AS fornecedornome
          ,produto.descricao
          ,produto.codigo AS codigoproduto
          ,grupoproduto.descricao AS grupoproduto
          ,grupoproduto_subgrupo.descricao AS subgrupoproduto
          ,notafiscalentrada_item_rateioveiculo.quantidade
          ,notafiscalentrada_item_rateioveiculo.valor AS valortotal
          ,CASE
                    WHEN notafiscalentrada_item.basepara = 1 THEN
                        'Outros'
                    WHEN notafiscalentrada_item.basepara = 4 THEN
                        'Lubrificantes'
                    WHEN notafiscalentrada_item.basepara = 5 THEN
                        'Lavagem'
                    ELSE
                        ''
           END AS basepara
          ,COALESCE(notafiscalentrada_item_rateioveiculo.diasgarantia,0) AS diasgarantia
          ,COALESCE(notafiscalentrada_item_rateioveiculo.marcadorgarantia,0) AS marcadorgarantia
          ,COALESCE(tipoveiculo.descricao,os_tipoveiculo.descricao) AS tipoveiculo
          ,COALESCE(notafiscalentrada.marcador,0) AS km
          ,COALESCE(notafiscalentrada.marcadorrefrigeracao,0) AS horimetro
          ,ordemservico.observacao::VARCHAR AS observacao
          ,notafiscalentrada_item.sequencia
          ,objetivoordemservico.descricao AS descricaoobjetivoos
          ,NULL::NUMERIC AS valortotalmaoobra
          ,NULL::NUMERIC AS valortotalpecas
          ,COALESCE(veiculo_marcador.diferencamarcador,0) AS diferencamarcador

      FROM  notafiscalentrada

        LEFT JOIN notafiscalentrada_item
            ON  notafiscalentrada_item.grupo = notafiscalentrada.grupo
            AND notafiscalentrada_item.empresa = notafiscalentrada.empresa
            AND notafiscalentrada_item.cnpjcpfcodigo = notafiscalentrada.cnpjcpfcodigo
            AND notafiscalentrada_item.dtemissao = notafiscalentrada.dtemissao
            AND notafiscalentrada_item.serie = notafiscalentrada.serie
            AND notafiscalentrada_item.numero = notafiscalentrada.numero

        LEFT JOIN notafiscalentrada_item_rateioveiculo
            ON  notafiscalentrada_item.grupo = notafiscalentrada_item_rateioveiculo.grupo
            AND notafiscalentrada_item.empresa = notafiscalentrada_item_rateioveiculo.empresa
            AND notafiscalentrada_item.cnpjcpfcodigo = notafiscalentrada_item_rateioveiculo.cnpjcpfcodigo
            AND notafiscalentrada_item.dtemissao = notafiscalentrada_item_rateioveiculo.dtemissao
            AND notafiscalentrada_item.serie = notafiscalentrada_item_rateioveiculo.serie
            AND notafiscalentrada_item.numero = notafiscalentrada_item_rateioveiculo.numero
            AND notafiscalentrada_item.sequencia = notafiscalentrada_item_rateioveiculo.sequencia

        LEFT JOIN ordemservico
            ON  ordemservico.grupo = Notafiscalentrada_item_rateioveiculo.grupoordemservico
            AND ordemservico.empresa = Notafiscalentrada_item_rateioveiculo.empresaordemservico
            AND ordemservico.filial = Notafiscalentrada_item_rateioveiculo.filialordemservico
            AND ordemservico.unidade = Notafiscalentrada_item_rateioveiculo.unidadeordemservico
            AND ordemservico.diferenciadornumero = Notafiscalentrada_item_rateioveiculo.diferenciadornumeroordemservico
            AND ordemservico.numero = Notafiscalentrada_item_rateioveiculo.numeroordemservico

        LEFT JOIN veiculo_marcador
            ON veiculo_marcador.grupo = ordemservico.grupo
            AND veiculo_marcador.empresa = ordemservico.empresa
            AND veiculo_marcador.filial = ordemservico.filial
            AND veiculo_marcador.unidade = ordemservico.unidade
            AND veiculo_marcador.diferenciadornumero = ordemservico.diferenciadornumero
            AND veiculo_marcador.numero = ordemservico.numero
            AND veiculo_marcador.tipodocumento = 33

      LEFT JOIN ordemservico_defeito
          ON  ordemservico_defeito.grupo = ordemservico.grupo
          AND ordemservico_defeito.empresa = ordemservico.empresa
          AND ordemservico_defeito.filial = ordemservico.filial
          AND ordemservico_defeito.unidade = ordemservico.unidade
          AND ordemservico_defeito.diferenciadornumero = ordemservico.diferenciadornumero
          AND ordemservico_defeito.numero = ordemservico.numero

      LEFT JOIN objetivoordemservico
          ON  ordemservico.objetivoordemservico = objetivoordemservico.codigo
          AND objetivoordemservico.grupo = ordemservico.grupo
          AND objetivoordemservico.empresa = ordemservico.empresa

      LEFT JOIN defeito
          ON  defeito.grupo = ordemservico_defeito.grupo
          AND defeito.empresa = ordemservico_defeito.empresa
          AND defeito.codigo = ordemservico_defeito.defeito

      LEFT JOIN cadastro fornecedor
          ON  fornecedor.codigo = notafiscalentrada.cnpjcpfcodigo

      LEFT JOIN produto
          ON  produto.codigo = notafiscalentrada_item.produto
          AND produto.grupo = notafiscalentrada_item.grupo
          AND produto.empresa = notafiscalentrada_item.empresa

      LEFT JOIN grupoproduto
          ON  grupoproduto.grupo = notafiscalentrada_item.grupo
          AND grupoproduto.empresa = notafiscalentrada_item.empresa
          AND grupoproduto.codigo = notafiscalentrada_item.grupoproduto

      LEFT JOIN grupoproduto_subgrupo
          ON  grupoproduto_subgrupo.grupo = notafiscalentrada_item.grupo
          AND grupoproduto_subgrupo.empresa = notafiscalentrada_item.empresa
          AND grupoproduto_subgrupo.grupoproduto = notafiscalentrada_item.grupoproduto
          AND grupoproduto_subgrupo.codigo = notafiscalentrada_item.subgrupoproduto

      LEFT JOIN veiculo
          ON  veiculo.placa = notafiscalentrada_item_rateioveiculo.veiculo

      LEFT JOIN tipoveiculo
          ON  tipoveiculo.codigo = veiculo.tipoveiculo

      LEFT JOIN veiculo AS os_veiculo
        ON os_veiculo.placa = ordemservico.veiculo

      LEFT JOIN tipoveiculo AS os_tipoveiculo
          ON os_tipoveiculo.codigo = os_veiculo.tipoveiculo

      WHERE
          notafiscalentrada.grupo = COALESCE(1,notafiscalentrada.grupo)
          AND notafiscalentrada.empresa = COALESCE(1,notafiscalentrada.empresa)
          AND notafiscalentrada.filial = COALESCE(NULL,notafiscalentrada.filial)
          AND notafiscalentrada.unidade = COALESCE(NULL,notafiscalentrada.unidade)
          AND notafiscalentrada.dtemissao BETWEEN '{initialDate}' AND '{finalDate}'
          AND CASE
                  WHEN '' = '' THEN
                      TRUE
                  ELSE
                       (notafiscalentrada_item_rateioveiculo.veiculo = '' OR ordemservico.veiculo = '')
              END
          AND notafiscalentrada_item.basepara IN (1, 4, 5) --1 - Outros, 2 - Abastecimento veiculo, 3 - Abastecimento refrigeracao, 4 - Lubrificantes, 5 - Lavagem, 6 - Pedagio, 7 - Carga/Descarga, 8 - Alimentacao
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto_subgrupo.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      produto.codigo = COALESCE('','')
              END
          AND CASE
                 WHEN COALESCE('Todas','') = '' THEN
                                TRUE
                  WHEN 'Todas' = 'Própria' THEN
                      veiculo.tipofrota = 1
                  WHEN 'Todas' = 'Agregada' THEN
                      veiculo.tipofrota = 3
                  WHEN 'Todas' = 'Terceira' THEN
                      veiculo.tipofrota = 2
                  WHEN 'Todas' = 'Todas' THEN
                      veiculo.tipofrota IN (1, 2, 3)
              END
          AND CASE
                  WHEN COALESCE(NULL,'') = '' THEN
                      TRUE
                  ELSE
                      veiculo.utilizacaoveiculo = COALESCE(NULL,'')
              END
          AND CASE COALESCE('AMBAS','AMBAS')
                  WHEN 'AMBAS' THEN
                      TRUE
                  WHEN 'INTERNA' THEN
                      (ordemservico.tipo = 1
                       OR COALESCE(ordemservico.numero,0) = 0)
                  WHEN 'EXTERNA' THEN
                      (ordemservico.tipo = 2
                       OR COALESCE(ordemservico.numero,0) = 0)
              END
      GROUP BY
          notafiscalentrada_item_rateioveiculo.veiculo
          ,ordemservico.veiculo
         ,veiculo.numerofrota
         ,notafiscalentrada.grupo ||
          '-' || notafiscalentrada.empresa ||
          '-' || notafiscalentrada.filial ||
          '-' || notafiscalentrada.unidade
         ,notafiscalentrada.dtentrada::DATE
         ,notafiscalentrada.dtemissao::DATE
         ,notafiscalentrada.serie
         ,notafiscalentrada.numero
         ,Notafiscalentrada_item_rateioveiculo.numeroordemservico
         ,fornecedor.razaosocial
         ,produto.descricao
         ,produto.codigo
         ,grupoproduto.descricao
         ,grupoproduto_subgrupo.descricao
         ,notafiscalentrada_item_rateioveiculo.quantidade
         ,notafiscalentrada_item_rateioveiculo.valor
         ,notafiscalentrada_item.basepara
         ,COALESCE(notafiscalentrada_item_rateioveiculo.diasgarantia,0)
         ,COALESCE(notafiscalentrada_item_rateioveiculo.marcadorgarantia,0)
         ,tipoveiculo.descricao
         ,notafiscalentrada.marcador
         ,notafiscalentrada.marcadorrefrigeracao
         ,ordemservico.observacao
         ,notafiscalentrada_item.sequencia
         ,objetivoordemservico.descricao
         ,veiculo_marcador.diferencamarcador
         ,os_tipoveiculo.descricao


      UNION ALL

      ------------------------BUSCA OS PNEUS UTILIZADOS------------------------------
      SELECT
          DISTINCT
          pneu_historico.veiculo
          ,veiculo.numerofrota
          ,pneu_historico.grupo || '-' || pneu_historico.empresa || '-' || pneu_historico.filial || '-' || pneu_historico.unidadelocado AS GEFU -- incluso
          ,'Pneu'::VARCHAR AS tipodocumento
          ,'Pneu'::VARCHAR AS tipodoc
          ,pneu_historico_ocorrencia.dtinc::DATE AS dtentrada
          ,pneu_historico.dtmontagem::DATE AS DTEMISSAO
          ,0::INTEGER AS DIFERENCIADORNUMERO
          ,pneu_historico_ocorrencia.serienotafiscalentrada AS serie
          ,pneu_historico_ocorrencia.numeronotafiscalentrada AS NUMERO
          ,NULL::INTEGER AS numeroordemservico
          ,''::VARCHAR AS descricaodefeito
          ,''::VARCHAR AS complemento
          ,FORNECEDOR.RAZAOSOCIAL AS FORNECEDORNOME
          ,pneu_historico_ocorrencia.pneu AS DESCRICAO
          ,''::VARCHAR AS codigoproduto
          ,''::VARCHAR AS GRUPOPRODUTO
          ,''::VARCHAR AS SUBGRUPOPRODUTO
          ,COALESCE(NULLIF(pneu_historico_ocorrencia.QUANTIDADE ,0),1) AS QUANTIDADE
          ,(COALESCE(SUM(pneu_historico_ocorrencia.valortotalreforma),0) + COALESCE(SUM(pneu_historico_ocorrencia.valor),0)) AS VALORTOTAL
          ,''::VARCHAR AS basepara
          ,0::INTEGER AS diasgarantia
          ,0::INTEGER AS marcadorgarantia
          ,tipoveiculo.descricao AS tipoveiculo
          ,NULL::INTEGER AS km
          ,NULL::INTEGER AS horimetro
          ,pneu_historico_ocorrencia.observacao::VARCHAR AS observacao
          ,NULL::INTEGER AS sequencia
          ,NULL AS descricaoobjetivoos
          ,NULL::NUMERIC AS valortotalmaoobra
          ,NULL::NUMERIC AS valortotalpecas
          ,COALESCE(pneu_historico.marcacaorodada,0) AS diferencamarcador

      FROM pneu

      JOIN pneu_historico
          ON  pneu_historico.grupo = pneu.grupo
          AND pneu_historico.empresa = pneu.empresa
          AND pneu_historico.pneu = pneu.numerofogo

      JOIN veiculo
          ON  veiculo.placa = pneu_historico.veiculo

      LEFT JOIN tipoveiculo
          ON  tipoveiculo.codigo = veiculo.tipoveiculo

      LEFT OUTER JOIN pneu_historico_ocorrencia
          ON  pneu_historico_ocorrencia.grupo = pneu_historico.grupo
          AND pneu_historico_ocorrencia.empresa = pneu_historico.empresa
          AND pneu_historico_ocorrencia.pneu = pneu_historico.pneu
          AND pneu_historico_ocorrencia.sequenciapneuhistoricoapropriacaoveiculo = pneu_historico.sequencia

      LEFT JOIN cadastro fornecedor
          ON  fornecedor.codigo = pneu_historico_ocorrencia.fornecedor

      WHERE
          pneu.grupo = COALESCE(1,pneu.grupo)
          AND pneu.empresa = COALESCE(1,pneu.empresa)
          AND pneu.filial = COALESCE(NULL,pneu.filial)
          AND pneu.unidadelocado = COALESCE(NULL,pneu.unidadelocado)
          AND (pneu_historico.dtmontagem BETWEEN '{initialDate}' AND '{finalDate}')
          AND CASE
                  WHEN '' = COALESCE('','') THEN
                      TRUE
                  ELSE
                      pneu_historico.veiculo = ''
              END
          AND (COALESCE((pneu_historico_ocorrencia.valortotalreforma),0) + COALESCE((pneu_historico_ocorrencia.valor),0))> 0
          AND COALESCE('','') = ''
          AND COALESCE('','') = ''
          AND COALESCE('','') = ''
          AND CASE
                   WHEN COALESCE('Todas','') = '' THEN
                                TRUE
                  WHEN 'Todas' = 'Própria' THEN
                      veiculo.tipofrota = 1
                  WHEN 'Todas' = 'Agregada' THEN
                      veiculo.tipofrota = 3
                  WHEN 'Todas' = 'Terceira' THEN
                      veiculo.tipofrota = 2
                  WHEN 'Todas' = 'Todas' THEN
                      veiculo.tipofrota IN (1, 2, 3)
              END
          AND CASE
                  WHEN COALESCE(NULL,'') = '' THEN
                      TRUE
                  ELSE
                      veiculo.utilizacaoveiculo = COALESCE(NULL,'')
              END
      GROUP BY
          pneu_historico.grupo
         ,pneu_historico.empresa
         ,pneu_historico.filial
         ,pneu_historico.unidadelocado
         ,pneu_historico_ocorrencia.dtinc::DATE
         ,pneu_historico.dtmontagem::DATE
         ,pneu_historico_ocorrencia.numeronotafiscalentrada
         ,pneu_historico_ocorrencia.serienotafiscalentrada
         ,FORNECEDOR.RAZAOSOCIAL
         ,pneu_historico_ocorrencia.pneu
         ,pneu_historico_ocorrencia.QUANTIDADE
         ,pneu_historico_ocorrencia.observacao
         ,pneu_historico.estadopneu
         ,pneu_historico.veiculo
         ,veiculo.numerofrota
         ,tipoveiculo.descricao
         ,pneu_historico.marcacaorodada

      UNION ALL




      ------------------------BUSCA O VALOR DE MÃO DE OBRA(SERVIÇO) NAS ORDENS DE SERVIÇO INTERNA------------------------------

      SELECT
          DISTINCT
          ordemservico.veiculo AS placa
          ,veiculo.numerofrota
          ,ordemservico.grupo || '-' || ordemservico.empresa || '-' || ordemservico.filial || '-' || ordemservico.unidade AS GEFU
          ,'Ordem de Serviço'::VARCHAR AS tipodocumento
          ,'O.S. Interna'::VARCHAR AS tipodoc
          ,ordemservico.dtemissao::DATE AS dtentrada
          ,ordemservico.dtemissao::DATE AS dtemisao
          ,ordemservico.diferenciadornumero AS diferenciadornumero
          ,0::INTEGER AS serie
          ,ordemservico.numero
          ,NULL::INTEGER AS numeroordemservico
          ,defeito.codigo || '-' || defeito.descricao AS descricaodefeito
          ,ordemservico_defeito.complemento AS complemento
          ,cadastrofornecedor.razaosocial AS fornecedornome
          ,''::VARCHAR AS descricao
          ,''::VARCHAR AS codigoproduto
          ,''::VARCHAR AS grupoproduto
          ,''::VARCHAR AS subgrupoproduto
          ,1::INTEGER AS quantidade
          ,COALESCE(SUM(ordemservico_defeito_servico_hora.valortotal),0) AS valortotal
          ,''::VARCHAR AS basepara
          ,0::INTEGER AS diasgarantia
          ,0::INTEGER AS marcadorgarantia
          ,tipoveiculo.descricao AS tipoveiculo
          ,CASE
               WHEN ordemservico.equipamentorefrigeracao = 2 THEN
                   ordemservico.marcadorveiculo
               ELSE
                   0
           END AS km
          ,CASE
               WHEN ordemservico.equipamentorefrigeracao = 1 THEN
                   ordemservico.marcadorveiculo
               ELSE
                   0
           END AS horimetro
          ,ordemservico.observacao AS observacao
          ,NULL::INTEGER AS sequencia
          ,objetivoordemservico.descricao AS descricaoobjetivoos
          ,SUM(ordemservico_defeito_servico_hora.valortotal) AS valortotalmaoobra
          ,NULL::NUMERIC AS valortotalpecas
          ,COALESCE(veiculo_marcador.diferencamarcador,0) AS diferencamarcador

      FROM ordemservico

      JOIN veiculo
          ON  veiculo.placa = ordemservico.veiculo

      LEFT JOIN tipoveiculo
          ON  tipoveiculo.codigo = veiculo.tipoveiculo

      LEFT JOIN objetivoordemservico
          ON  ordemservico.objetivoordemservico = objetivoordemservico.codigo
          AND objetivoordemservico.grupo = ordemservico.grupo
          AND objetivoordemservico.empresa = ordemservico.empresa

      JOIN ordemservico_defeito
          ON  ordemservico_defeito.grupo = ordemservico.grupo
          AND ordemservico_defeito.empresa = ordemservico.empresa
          AND ordemservico_defeito.filial = ordemservico.filial
          AND ordemservico_defeito.unidade = ordemservico.unidade
          AND ordemservico_defeito.diferenciadornumero = ordemservico.diferenciadornumero
          AND ordemservico_defeito.numero = ordemservico.numero

       LEFT JOIN ordemservico_defeito_servico_hora
          ON  ordemservico_defeito.grupo = ordemservico_defeito_servico_hora.grupo
          AND ordemservico_defeito.empresa = ordemservico_defeito_servico_hora.empresa
          AND ordemservico_defeito.filial = ordemservico_defeito_servico_hora.filial
          AND ordemservico_defeito.unidade = ordemservico_defeito_servico_hora.unidade
          AND ordemservico_defeito.diferenciadornumero = ordemservico_defeito_servico_hora.diferenciadornumero
          AND ordemservico_defeito.numero = ordemservico_defeito_servico_hora.numero
          AND ordemservico_defeito.sequencia = ordemservico_defeito_servico_hora.sequencia

      JOIN defeito
          ON  defeito.grupo = ordemservico_defeito.grupo
          AND defeito.empresa = ordemservico_defeito.empresa
          AND defeito.codigo = ordemservico_defeito.defeito

      JOIN empresa_configuracao
          ON  empresa_configuracao.grupo = ordemservico.grupo
          AND empresa_configuracao.empresa = ordemservico.empresa


       LEFT JOIN cadastro cadastrofornecedor
         ON  cadastrofornecedor.codigo = ordemservico.fornecedor


       LEFT JOIN veiculo_marcador
          ON veiculo_marcador.grupo = ordemservico.grupo
          AND veiculo_marcador.empresa = ordemservico.empresa
          AND veiculo_marcador.filial = ordemservico.filial
          AND veiculo_marcador.unidade = ordemservico.unidade
          AND veiculo_marcador.diferenciadornumero = ordemservico.diferenciadornumero
          AND veiculo_marcador.numero = ordemservico.numero
          AND veiculo_marcador.tipodocumento = 33

      WHERE
          ordemservico.grupo = COALESCE(1,ordemservico.grupo)
          AND ordemservico.empresa = COALESCE(1,ordemservico.empresa)
          AND ordemservico.filial = COALESCE(NULL,ordemservico.filial)
          AND ordemservico.unidade = COALESCE(NULL,ordemservico.unidade)
          AND ordemservico.tipo = 1
          AND ordemservico.dtemissao::DATE BETWEEN '{initialDate}' AND '{finalDate}'
          AND ordemservico.veiculo IS NOT NULL
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      ordemservico.veiculo = ''
              END
          AND COALESCE('','') = ''
          AND COALESCE('','') = ''
          AND COALESCE('','') = ''
          AND CASE
                  WHEN COALESCE('Todas','') = '' THEN
                                TRUE
                  WHEN 'Todas' = 'Própria' THEN
                      veiculo.tipofrota = 1
                  WHEN 'Todas' = 'Agregada' THEN
                      veiculo.tipofrota = 3
                  WHEN 'Todas' = 'Terceira' THEN
                      veiculo.tipofrota = 2
                  WHEN 'Todas' = 'Todas' THEN
                      veiculo.tipofrota IN (1, 2, 3)
              END
          AND CASE
                  WHEN COALESCE(NULL,'') = '' THEN
                      TRUE
                  ELSE
                      veiculo.utilizacaoveiculo = COALESCE(NULL,'')
              END
          AND CASE COALESCE('AMBAS','AMBAS')
                  WHEN 'AMBAS' THEN
                      TRUE
                  WHEN 'INTERNA' THEN
                      ordemservico.tipo = 1
                  WHEN 'EXTERNA' THEN
                      ordemservico.tipo = 2
              END
      GROUP BY
          ordemservico.veiculo
         ,veiculo.numerofrota
         ,ordemservico.grupo || '-' || ordemservico.empresa || '-' || ordemservico.filial || '-' || ordemservico.unidade
         ,ordemservico.dtemissao::DATE
         ,ordemservico.dtemissao::DATE
         ,ordemservico.diferenciadornumero
         ,ordemservico.numero
         ,defeito.codigo || '-' || defeito.descricao
         ,ordemservico_defeito.complemento
         ,(COALESCE(ordemservico.valortotalmaoobra,0) + COALESCE(ordemservico.valortotalmaoobranfeservicos,0))
         ,tipoveiculo.descricao
         ,ordemservico.equipamentorefrigeracao
         ,ordemservico.marcadorveiculo
         ,ordemservico.observacao
         ,objetivoordemservico.descricao
         ,ordemservico.valortotalmaoobra
         ,ordemservico.valortotalpecas
         ,ordemservico.tipo
         ,empresa_configuracao.utilizarvaloresordensservicoexterna
         ,veiculo_marcador.diferencamarcador
         ,cadastrofornecedor.razaosocial

      UNION ALL

      ------------------------BUSCA OS ITENS NAS ORDENS DE SERVIÇO INTERNA------------------------------

      SELECT
          ordemservico.veiculo AS placa
          ,veiculo.numerofrota
          ,ordemservico.grupo || '-' || ordemservico.empresa || '-' || ordemservico.filial || '-' || ordemservico.unidade AS GEFU
          ,'Ordem de Serviço'::VARCHAR AS tipodocumento
          ,'O.S. Interna'::VARCHAR AS tipodoc
          ,requisicaomaterial_item.dtinc::DATE AS dtentrada
          ,ordemservico.dtemissao::DATE AS dtemisao
          ,ordemservico.diferenciadornumero AS diferenciadornumero
          ,0::INTEGER AS serie
          ,ordemservico.numero
          ,NULL AS numeroordemservico
          ,''::VARCHAR AS descricaodefeito
          ,''::VARCHAR AS complemento
          ,cadastrofornecedor.razaosocial AS fornecedornome
          ,produto.descricao
          ,produto.codigo AS codigoproduto
          ,grupoproduto.descricao AS grupoproduto
          ,grupoproduto_subgrupo.descricao AS subgrupoproduto
          ,requisicaomaterial_item.quantidade
          ,COALESCE(requisicaomaterial_item.quantidade::NUMERIC(15,2),0) * COALESCE(requisicaomaterial_item.valorunitario::NUMERIC(15,2),0) AS valortotal
          ,''::VARCHAR AS basepara
          ,COALESCE(requisicaomaterial_item.diasgarantia,0) AS diasgarantia
          ,COALESCE(requisicaomaterial_item.marcadorgarantia,0) AS marcadorgarantia
          ,tipoveiculo.descricao AS tipoveiculo
          ,CASE
               WHEN ordemservico.equipamentorefrigeracao = 2 THEN
                   ordemservico.marcadorveiculo
               ELSE
                   0
           END AS km
          ,CASE
               WHEN ordemservico.equipamentorefrigeracao = 1 THEN
                   ordemservico.marcadorveiculo
               ELSE
                   0
           END AS horimetro
          ,requisicaomaterial_item.observacao::VARCHAR AS observacao
          ,NULL AS sequencia
          ,objetivoordemservico.descricao AS descricaoobjetivoos
          ,NULL AS valortotalmaoobra
          ,(requisicaomaterial_item.quantidade * requisicaomaterial_item.valorunitario) AS valortotalpecas
          ,COALESCE(veiculo_marcador.diferencamarcador,0) AS diferencamarcador


      FROM ordemservico

      JOIN veiculo
          ON  veiculo.placa = ordemservico.veiculo

      JOIN tipoveiculo
          ON  tipoveiculo.codigo = veiculo.tipoveiculo

      LEFT JOIN objetivoordemservico
          ON  ordemservico.objetivoordemservico = objetivoordemservico.codigo
          AND objetivoordemservico.grupo = ordemservico.grupo
          AND objetivoordemservico.empresa = ordemservico.empresa

      JOIN requisicaomaterial
          ON  requisicaomaterial.grupo = ordemservico.grupo
          AND requisicaomaterial.empresa = ordemservico.empresa
          AND requisicaomaterial.filial = ordemservico.filial
          AND requisicaomaterial.unidade = ordemservico.unidade
          AND requisicaomaterial.diferenciadornumeroordemservico = ordemservico.diferenciadornumero
          AND requisicaomaterial.numeroordemservico = ordemservico.numero

      JOIN requisicaomaterial_item
          ON  requisicaomaterial_item.grupo = requisicaomaterial.grupo
          AND requisicaomaterial_item.empresa = requisicaomaterial.empresa
          AND requisicaomaterial_item.filial = requisicaomaterial.filial
          AND requisicaomaterial_item.unidade = requisicaomaterial.unidade
          AND requisicaomaterial_item.diferenciadornumero = requisicaomaterial.diferenciadornumero
          AND requisicaomaterial_item.numero = requisicaomaterial.numero

      JOIN produto
          ON  produto.grupo = requisicaomaterial_item.grupo
          AND produto.empresa = requisicaomaterial_item.empresa
          AND produto.codigo = requisicaomaterial_item.produto

      JOIN grupoproduto
          ON  grupoproduto.grupo = requisicaomaterial_item.grupo
          AND grupoproduto.empresa = requisicaomaterial_item.empresa
          AND grupoproduto.codigo = requisicaomaterial_item.grupoproduto

      JOIN grupoproduto_subgrupo
          ON  grupoproduto_subgrupo.grupo = requisicaomaterial_item.grupo
          AND grupoproduto_subgrupo.empresa = requisicaomaterial_item.grupo
          AND grupoproduto_subgrupo.grupoproduto = requisicaomaterial_item.grupoproduto
          AND grupoproduto_subgrupo.codigo = requisicaomaterial_item.subgrupoproduto

      JOIN empresa_configuracao
          ON  empresa_configuracao.grupo = ordemservico.grupo
          AND empresa_configuracao.empresa = ordemservico.empresa


         LEFT JOIN cadastro cadastrofornecedor
         ON  cadastrofornecedor.codigo = ordemservico.fornecedor


      LEFT JOIN veiculo_marcador
          ON veiculo_marcador.grupo = ordemservico.grupo
          AND veiculo_marcador.empresa = ordemservico.empresa
          AND veiculo_marcador.filial = ordemservico.filial
          AND veiculo_marcador.unidade = ordemservico.unidade
          AND veiculo_marcador.diferenciadornumero = ordemservico.diferenciadornumero
          AND veiculo_marcador.numero = ordemservico.numero
          AND veiculo_marcador.tipodocumento = 33


      WHERE
          ordemservico.grupo = COALESCE(1,ordemservico.grupo)
          AND ordemservico.empresa = COALESCE(1,ordemservico.empresa)
          AND ordemservico.filial = COALESCE(NULL,ordemservico.filial)
          AND ordemservico.unidade = COALESCE(NULL,ordemservico.unidade)
          AND ordemservico.tipo = 1
          AND CASE COALESCE('AMBAS','AMBAS')
                  WHEN 'AMBAS' THEN
                      TRUE
                  WHEN 'INTERNA' THEN
                      TRUE
                  WHEN 'EXTERNA' THEN
                      FALSE
              END
          AND ordemservico.veiculo IS NOT NULL
          AND ordemservico.dtemissao::DATE BETWEEN '{initialDate}' AND '{finalDate}'
          AND CASE
                  WHEN '' = '' THEN
                      TRUE
                  ELSE
                      ordemservico.veiculo = ''
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto_subgrupo.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      produto.codigo = COALESCE('','')
              END
          AND CASE
                   WHEN COALESCE('Todas','') = '' THEN
                                TRUE
                  WHEN 'Todas' = 'Própria' THEN
                      veiculo.tipofrota = 1
                  WHEN 'Todas' = 'Agregada' THEN
                      veiculo.tipofrota = 3
                  WHEN 'Todas' = 'Terceira' THEN
                      veiculo.tipofrota = 2
                  WHEN 'Todas' = 'Todas' THEN
                      veiculo.tipofrota IN (1, 2, 3)
              END
          AND CASE
                  WHEN COALESCE(NULL,'') = '' THEN
                      TRUE
                  ELSE
                      veiculo.utilizacaoveiculo = COALESCE(NULL,'')
              END

       GROUP BY
          ordemservico.veiculo
         ,veiculo.numerofrota
         ,ordemservico.grupo || '-' || ordemservico.empresa || '-' || ordemservico.filial || '-' || ordemservico.unidade
         ,ordemservico.dtemissao::DATE
         ,ordemservico.dtemissao::DATE
         ,ordemservico.diferenciadornumero
         ,ordemservico.numero
         ,(COALESCE(ordemservico.valortotalmaoobra,0) + COALESCE(ordemservico.valortotalmaoobranfeservicos,0))
         ,tipoveiculo.descricao
         ,ordemservico.equipamentorefrigeracao
         ,ordemservico.marcadorveiculo
         ,ordemservico.observacao
         ,objetivoordemservico.descricao
         ,ordemservico.valortotalmaoobra
         ,ordemservico.valortotalpecas
         ,ordemservico.tipo
         ,empresa_configuracao.utilizarvaloresordensservicoexterna
         ,requisicaomaterial_item.dtinc
         ,produto.descricao
         , produto.codigo
         ,grupoproduto.descricao
         ,grupoproduto_subgrupo.descricao
         ,requisicaomaterial_item.quantidade
         ,requisicaomaterial_item.diasgarantia
         ,requisicaomaterial_item.marcadorgarantia
         ,requisicaomaterial_item.observacao
         ,requisicaomaterial_item.valorunitario
         ,veiculo_marcador.diferencamarcador
         ,cadastrofornecedor.razaosocial



              ------------------------------------------ ORDEM DE SERVIÇO EXTERNA -----------------------------
               UNION ALL

      ------------------------ BUSCA O VALOR DE MÃO DE OBRA(SERVIÇO) NAS ORDENS DE SERVIÇO EXTERNA ------------------------------

      SELECT
          DISTINCT
          ordemservico.veiculo AS placa
          ,veiculo.numerofrota
          ,ordemservico.grupo || '-' || ordemservico.empresa || '-' || ordemservico.filial || '-' || ordemservico.unidade AS GEFU
          ,'Ordem de Serviço'::VARCHAR AS tipodocumento
          ,'O.S. Externa'::VARCHAR AS tipodoc
          ,ordemservico.dtemissao::DATE AS dtentrada
          ,ordemservico.dtemissao::DATE AS dtemisao
          ,ordemservico.diferenciadornumero AS diferenciadornumero
          ,0::INTEGER AS serie
          ,ordemservico.numero
          ,NULL::INTEGER AS numeroordemservico
          ,defeito.codigo || '-' || defeito.descricao AS descricaodefeito
          ,ordemservico_defeito.complemento AS complemento
          ,cadastrofornecedor.razaosocial AS fornecedornome
          ,''::VARCHAR AS descricao
          ,''::VARCHAR AS codigoproduto
          ,''::VARCHAR AS grupoproduto
          ,''::VARCHAR AS subgrupoproduto
          ,1::INTEGER AS quantidade
          ,COALESCE(SUM(ordemservico_defeito_servico_hora.valortotal),0) AS valortotal
          ,''::VARCHAR AS basepara
          ,0::INTEGER AS diasgarantia
          ,0::INTEGER AS marcadorgarantia
          ,tipoveiculo.descricao AS tipoveiculo
          ,CASE
               WHEN ordemservico.equipamentorefrigeracao = 2 THEN
                   ordemservico.marcadorveiculo
               ELSE
                   0
           END AS km
          ,CASE
               WHEN ordemservico.equipamentorefrigeracao = 1 THEN
                   ordemservico.marcadorveiculo
               ELSE
                   0
           END AS horimetro
          ,ordemservico.observacao AS observacao
          ,NULL::INTEGER AS sequencia
          ,objetivoordemservico.descricao AS descricaoobjetivoos
          ,SUM(ordemservico_defeito_servico_hora.valortotal) AS valortotalmaoobra
          ,NULL::NUMERIC AS valortotalpecas
          ,COALESCE(veiculo_marcador.diferencamarcador,0) AS diferencamarcador

      FROM ordemservico

      JOIN veiculo
          ON  veiculo.placa = ordemservico.veiculo

      LEFT JOIN tipoveiculo
          ON  tipoveiculo.codigo = veiculo.tipoveiculo

      LEFT JOIN objetivoordemservico
          ON  ordemservico.objetivoordemservico = objetivoordemservico.codigo
          AND objetivoordemservico.grupo = ordemservico.grupo
          AND objetivoordemservico.empresa = ordemservico.empresa

      JOIN ordemservico_defeito
          ON  ordemservico_defeito.grupo = ordemservico.grupo
          AND ordemservico_defeito.empresa = ordemservico.empresa
          AND ordemservico_defeito.filial = ordemservico.filial
          AND ordemservico_defeito.unidade = ordemservico.unidade
          AND ordemservico_defeito.diferenciadornumero = ordemservico.diferenciadornumero
          AND ordemservico_defeito.numero = ordemservico.numero

      LEFT JOIN ordemservico_defeito_servico_hora
          ON  ordemservico_defeito.grupo = ordemservico_defeito_servico_hora.grupo
          AND ordemservico_defeito.empresa = ordemservico_defeito_servico_hora.empresa
          AND ordemservico_defeito.filial = ordemservico_defeito_servico_hora.filial
          AND ordemservico_defeito.unidade = ordemservico_defeito_servico_hora.unidade
          AND ordemservico_defeito.diferenciadornumero = ordemservico_defeito_servico_hora.diferenciadornumero
          AND ordemservico_defeito.numero = ordemservico_defeito_servico_hora.numero
          AND ordemservico_defeito.sequencia = ordemservico_defeito_servico_hora.sequencia

      JOIN defeito
          ON  defeito.grupo = ordemservico_defeito.grupo
          AND defeito.empresa = ordemservico_defeito.empresa
          AND defeito.codigo = ordemservico_defeito.defeito

      JOIN empresa_configuracao
          ON  empresa_configuracao.grupo = ordemservico.grupo
          AND empresa_configuracao.empresa = ordemservico.empresa



      LEFT JOIN cadastro cadastrofornecedor
         ON  cadastrofornecedor.codigo = ordemservico.fornecedor


      LEFT JOIN veiculo_marcador
          ON veiculo_marcador.grupo = ordemservico.grupo
          AND veiculo_marcador.empresa = ordemservico.empresa
          AND veiculo_marcador.filial = ordemservico.filial
          AND veiculo_marcador.unidade = ordemservico.unidade
          AND veiculo_marcador.diferenciadornumero = ordemservico.diferenciadornumero
          AND veiculo_marcador.numero = ordemservico.numero
          AND veiculo_marcador.tipodocumento = 33


      WHERE
          ordemservico.grupo = COALESCE(1,ordemservico.grupo)
          AND ordemservico.empresa = COALESCE(1,ordemservico.empresa)
          AND ordemservico.filial = COALESCE(NULL,ordemservico.filial)
          AND ordemservico.unidade = COALESCE(NULL,ordemservico.unidade)
          AND ordemservico.tipo = 2
          AND CASE COALESCE('AMBAS','AMBAS')
                  WHEN 'AMBAS' THEN
                      TRUE
                  WHEN 'INTERNA' THEN
                      FALSE
                  WHEN 'EXTERNA' THEN
                      TRUE
              END
              --AND ordemservico.valortotalmaoobra <> 0
          AND ordemservico.dtemissao::DATE BETWEEN '{initialDate}' AND '{finalDate}'
          AND ordemservico.veiculo IS NOT NULL
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      ordemservico.veiculo = ''
              END
          AND COALESCE('','') = ''
          AND COALESCE('','') = ''
          AND COALESCE('','') = ''
          AND CASE
                  WHEN COALESCE('Todas','') = '' THEN
                                TRUE
                  WHEN 'Todas' = 'Própria' THEN
                      veiculo.tipofrota = 1
                  WHEN 'Todas' = 'Agregada' THEN
                      veiculo.tipofrota = 3
                  WHEN 'Todas' = 'Terceira' THEN
                      veiculo.tipofrota = 2
                  WHEN 'Todas' = 'Todas' THEN
                      veiculo.tipofrota IN (1, 2, 3)
              END
          AND CASE
                  WHEN COALESCE(NULL,'') = '' THEN
                      TRUE
                  ELSE
                      veiculo.utilizacaoveiculo = COALESCE(NULL,'')
              END
      GROUP BY
          ordemservico.veiculo
         ,veiculo.numerofrota
         ,ordemservico.grupo || '-' || ordemservico.empresa || '-' || ordemservico.filial || '-' || ordemservico.unidade
         ,ordemservico.dtemissao::DATE
         ,ordemservico.dtemissao::DATE
         ,ordemservico.diferenciadornumero
         ,ordemservico.numero
         ,defeito.codigo || '-' || defeito.descricao
         ,ordemservico_defeito.complemento
         ,(COALESCE(ordemservico.valortotalmaoobra,0) + COALESCE(ordemservico.valortotalmaoobranfeservicos,0))
         ,tipoveiculo.descricao
         ,ordemservico.equipamentorefrigeracao
         ,ordemservico.marcadorveiculo
         ,ordemservico.observacao
         ,objetivoordemservico.descricao
         ,ordemservico.valortotalmaoobra
         ,ordemservico.valortotalpecas
         ,ordemservico.tipo
         ,empresa_configuracao.utilizarvaloresordensservicoexterna
         ,veiculo_marcador.diferencamarcador
         ,cadastrofornecedor.razaosocial



      UNION ALL

      ------------------------BUSCA OS ITENS NAS ORDENS DE SERVIÇO EXTERNA------------------------------

      SELECT
          DISTINCT
          ordemservico.veiculo AS placa
          ,veiculo.numerofrota
          ,ordemservico.grupo || '-' || ordemservico.empresa || '-' || ordemservico.filial || '-' || ordemservico.unidade AS GEFU
          ,'Ordem de Serviço'::VARCHAR AS tipodocumento
          ,'O.S. Externa'::VARCHAR AS tipodoc
          ,requisicaomaterial_item.dtinc::DATE AS dtentrada
          ,ordemservico.dtemissao::DATE AS dtemisao
          ,ordemservico.diferenciadornumero AS diferenciadornumero
          ,0::INTEGER AS serie
          ,ordemservico.numero
          ,NULL::INTEGER AS numeroordemservico
          ,''::VARCHAR AS descricaodefeito
          ,''::VARCHAR AS complemento
          ,cadastrofornecedor.razaosocial AS fornecedornome
          ,produto.descricao
          ,produto.codigo AS codigoproduto
          ,grupoproduto.descricao AS grupoproduto
          ,grupoproduto_subgrupo.descricao AS subgrupoproduto
          ,requisicaomaterial_item.quantidade
          ,COALESCE(requisicaomaterial_item.valortotal,0) AS valortotal
          ,''::VARCHAR AS basepara
          ,COALESCE(requisicaomaterial_item.diasgarantia,0) AS diasgarantia
          ,COALESCE(requisicaomaterial_item.marcadorgarantia,0) AS marcadorgarantia
          ,tipoveiculo.descricao AS tipoveiculo
          ,CASE
               WHEN ordemservico.equipamentorefrigeracao = 2 THEN
                   ordemservico.marcadorveiculo
               ELSE
                   0
           END AS km
          ,CASE
               WHEN ordemservico.equipamentorefrigeracao = 1 THEN
                   ordemservico.marcadorveiculo
               ELSE
                   0
           END AS horimetro
          ,requisicaomaterial_item.observacao::VARCHAR AS observacao
          ,NULL::INTEGER AS sequencia
          ,objetivoordemservico.descricao AS descricaoobjetivoos
          ,NULL::INTEGER AS valortotalmaoobra
          ,requisicaomaterial_item.valorunitario AS valortotalpecas
          ,COALESCE(veiculo_marcador.diferencamarcador,0) AS diferencamarcador

      FROM ordemservico

      JOIN veiculo
          ON  veiculo.placa = ordemservico.veiculo

      JOIN tipoveiculo
          ON  tipoveiculo.codigo = veiculo.tipoveiculo

      JOIN requisicaomaterial
          ON  requisicaomaterial.grupo = ordemservico.grupo
          AND requisicaomaterial.empresa = ordemservico.empresa
          AND requisicaomaterial.filial = ordemservico.filial
          AND requisicaomaterial.unidade = ordemservico.unidade
          AND requisicaomaterial.diferenciadornumeroordemservico = ordemservico.diferenciadornumero
          AND requisicaomaterial.numeroordemservico = ordemservico.numero

      LEFT JOIN objetivoordemservico
          ON  ordemservico.objetivoordemservico = objetivoordemservico.codigo
          AND objetivoordemservico.grupo = ordemservico.grupo
          AND objetivoordemservico.empresa = ordemservico.empresa

      JOIN requisicaomaterial_item
          ON  requisicaomaterial_item.grupo = requisicaomaterial.grupo
          AND requisicaomaterial_item.empresa = requisicaomaterial.empresa
          AND requisicaomaterial_item.filial = requisicaomaterial.filial
          AND requisicaomaterial_item.unidade = requisicaomaterial.unidade
          AND requisicaomaterial_item.diferenciadornumero = requisicaomaterial.diferenciadornumero
          AND requisicaomaterial_item.numero = requisicaomaterial.numero

      JOIN produto
          ON  produto.grupo = requisicaomaterial_item.grupo
          AND produto.empresa = requisicaomaterial_item.empresa
          AND produto.codigo = requisicaomaterial_item.produto

      JOIN grupoproduto
          ON  grupoproduto.grupo = requisicaomaterial_item.grupo
          AND grupoproduto.empresa = requisicaomaterial_item.empresa
          AND grupoproduto.codigo = requisicaomaterial_item.grupoproduto

      JOIN grupoproduto_subgrupo
          ON  grupoproduto_subgrupo.grupo = requisicaomaterial_item.grupo
          AND grupoproduto_subgrupo.empresa = requisicaomaterial_item.grupo
          AND grupoproduto_subgrupo.grupoproduto = requisicaomaterial_item.grupoproduto
          AND grupoproduto_subgrupo.codigo = requisicaomaterial_item.subgrupoproduto

      JOIN empresa_configuracao
          ON  empresa_configuracao.grupo = ordemservico.grupo
          AND empresa_configuracao.empresa = ordemservico.empresa


       LEFT JOIN cadastro cadastrofornecedor
         ON  cadastrofornecedor.codigo = ordemservico.fornecedor

       LEFT JOIN veiculo_marcador
          ON veiculo_marcador.grupo = ordemservico.grupo
          AND veiculo_marcador.empresa = ordemservico.empresa
          AND veiculo_marcador.filial = ordemservico.filial
          AND veiculo_marcador.unidade = ordemservico.unidade
          AND veiculo_marcador.diferenciadornumero = ordemservico.diferenciadornumero
          AND veiculo_marcador.numero = ordemservico.numero
          AND veiculo_marcador.tipodocumento = 33


      WHERE
          ordemservico.grupo = COALESCE(1,ordemservico.grupo)
          AND ordemservico.empresa = COALESCE(1,ordemservico.empresa)
          AND ordemservico.filial = COALESCE(NULL,ordemservico.filial)
          AND ordemservico.unidade = COALESCE(NULL,ordemservico.unidade)
          AND ordemservico.tipo = 2
          AND CASE COALESCE('AMBAS','AMBAS')
                  WHEN 'AMBAS' THEN
                      TRUE
                  WHEN 'INTERNA' THEN
                      FALSE
                  WHEN 'EXTERNA' THEN
                      TRUE
              END
          AND ordemservico.veiculo IS NOT NULL
          AND ordemservico.dtemissao::DATE BETWEEN '{initialDate}' AND '{finalDate}'
          AND CASE
                  WHEN '' = '' THEN
                      TRUE
                  ELSE
                      ordemservico.veiculo = ''
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto_subgrupo.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      produto.codigo = COALESCE('','')
              END
          AND CASE
                   WHEN COALESCE('Todas','') = '' THEN
                                TRUE
                  WHEN 'Todas' = 'Própria' THEN
                      veiculo.tipofrota = 1
                  WHEN 'Todas' = 'Agregada' THEN
                      veiculo.tipofrota = 3
                  WHEN 'Todas' = 'Terceira' THEN
                      veiculo.tipofrota = 2
                  WHEN 'Todas' = 'Todas' THEN
                      veiculo.tipofrota IN (1, 2, 3)
              END
          AND CASE
                  WHEN COALESCE(NULL,'') = '' THEN
                      TRUE
                  ELSE
                      veiculo.utilizacaoveiculo = COALESCE(NULL,'')
              END

      GROUP BY
          ordemservico.veiculo
         ,veiculo.numerofrota
         ,ordemservico.grupo || '-' || ordemservico.empresa || '-' || ordemservico.filial || '-' || ordemservico.unidade
         ,ordemservico.dtemissao::DATE
         ,ordemservico.dtemissao::DATE
         ,ordemservico.diferenciadornumero
         ,ordemservico.numero
         ,(COALESCE(ordemservico.valortotalmaoobra,0) + COALESCE(ordemservico.valortotalmaoobranfeservicos,0))
         ,tipoveiculo.descricao
         ,ordemservico.equipamentorefrigeracao
         ,ordemservico.marcadorveiculo
         ,ordemservico.observacao
         ,objetivoordemservico.descricao
         ,ordemservico.valortotalmaoobra
         ,ordemservico.valortotalpecas
         ,ordemservico.tipo
         ,empresa_configuracao.utilizarvaloresordensservicoexterna
         ,requisicaomaterial_item.dtinc
         ,produto.descricao
         ,produto.codigo
         ,grupoproduto.descricao
         ,grupoproduto_subgrupo.descricao
         ,requisicaomaterial_item.quantidade
         ,requisicaomaterial_item.diasgarantia
         ,requisicaomaterial_item.marcadorgarantia
         ,requisicaomaterial_item.observacao
         ,veiculo_marcador.diferencamarcador
         ,requisicaomaterial_item.valortotal
         ,requisicaomaterial_item.valorunitario
         ,cadastrofornecedor.razaosocial


      UNION ALL

      ------------------------BUSCA OS ITENS NAS NOTAS SIMPLIFICADAS QUE A BASE PARA SEJA = 1 - Outros, 4 - Lubrificantes E 5 - Lavagem QUE O tipocombustivel = 1------------------------------
      SELECT
          DISTINCT
          notafiscalsimples.veiculo AS placa
          ,veiculo.numerofrota
          ,notafiscalsimples.grupo || '-' || notafiscalsimples.empresa || '-' || notafiscalsimples.filial || '-' || notafiscalsimples.unidade AS GEFU
          ,'NF Simplificada'::VARCHAR AS tipodocumento
          ,'NF Simples'::VARCHAR AS tipodoc
          ,notafiscalsimples.dtentrada::DATE AS dtentrada
          ,notafiscalsimples.dtemissao
          ,notafiscalsimples.diferenciadorsequencia AS diferenciadornumero
          ,0::INTEGER AS SERIE
          ,notafiscalsimples.sequencia AS numero
          ,NULL::INTEGER AS numeroordemservico
           --,notafiscalsimples.numero
          ,''::VARCHAR AS descricaodefeito
          ,''::VARCHAR AS complemento
          ,fornecedor.razaosocial AS fornecedornome
          ,produto.descricao
          ,produto.codigo AS codigoproduto
          ,grupoproduto.descricao AS grupoproduto
          ,grupoproduto_subgrupo.descricao AS subgrupoproduto
          ,notafiscalsimples_item.quantidade
          ,notafiscalsimples_item.valortotalmoedautilizada
          ,CASE
                WHEN notafiscalsimples_item.basepara = 1 THEN
                    'Outros'
                WHEN notafiscalsimples_item.basepara = 4 THEN
                    'Lubrificantes'
                WHEN notafiscalsimples_item.basepara = 5 THEN
                    'Lavagem'
                ELSE
                    ''
          END AS basepara
          ,0::INTEGER AS diasgarantia
          ,0::INTEGER AS marcadorgarantia
          ,tipoveiculo.descricao AS tipoveiculo
          ,COALESCE(notafiscalsimples.marcador,0) AS km
          ,COALESCE(notafiscalsimples.marcadorrefrigeracao,0) AS horimetro
          ,''::VARCHAR AS observacao
          ,notafiscalsimples_item.sequencia AS sequencia
          ,NULL AS descricaoobjetivoos
          ,NULL::NUMERIC AS valortotalmaoobra
          ,NULL::NUMERIC AS valortotalpecas
          ,COALESCE(notafiscalsimples.diferencamarcador,0) AS diferencamarcador

      FROM notafiscalsimples

      JOIN veiculo
          ON  veiculo.placa = notafiscalsimples.veiculo

      JOIN tipoveiculo
          ON  tipoveiculo.codigo = veiculo.tipoveiculo

      JOIN notafiscalsimples_item
          ON  notafiscalsimples_item.grupo = notafiscalsimples.grupo
          AND notafiscalsimples_item.empresa = notafiscalsimples.empresa
          AND notafiscalsimples_item.filial = notafiscalsimples.filial
          AND notafiscalsimples_item.unidade = notafiscalsimples.unidade
          AND notafiscalsimples_item.diferenciadorsequencia = notafiscalsimples.diferenciadorsequencia
          AND notafiscalsimples_item.sequencia = notafiscalsimples.sequencia

      JOIN produto
          ON  produto.grupo = notafiscalsimples_item.grupo
          AND produto.empresa = notafiscalsimples_item.empresa
          AND produto.codigo = notafiscalsimples_item.produto

      JOIN grupoproduto
          ON  grupoproduto.grupo = notafiscalsimples_item.grupo
          AND grupoproduto.empresa = notafiscalsimples_item.empresa
          AND grupoproduto.codigo = notafiscalsimples_item.grupoproduto

      JOIN grupoproduto_subgrupo
          ON  grupoproduto_subgrupo.grupo = notafiscalsimples_item.grupo
          AND grupoproduto_subgrupo.empresa = notafiscalsimples_item.empresa
          AND grupoproduto_subgrupo.grupoproduto = notafiscalsimples_item.grupoproduto
          AND grupoproduto_subgrupo.codigo = notafiscalsimples_item.subgrupoproduto

      LEFT JOIN cadastro fornecedor
          ON  fornecedor.codigo = notafiscalsimples.fornecedor


      WHERE
          notafiscalsimples.grupo = COALESCE(1,notafiscalsimples.grupo)
          AND notafiscalsimples.empresa = COALESCE(1,notafiscalsimples.empresa)
          AND notafiscalsimples.filial = COALESCE(NULL,notafiscalsimples.filial)
          AND notafiscalsimples.unidade = COALESCE(NULL,notafiscalsimples.unidade)
          AND notafiscalsimples.tipodocumento = 30
          AND notafiscalsimples.veiculo IS NOT NULL
          AND notafiscalsimples_item.basepara IN (1, 4, 5) --1 - Outros, 2 - Abastecimento veiculo, 3 - Abastecimento refrigeracao, 4 - Lubrificantes, 5 - Lavagem, 6 - Pedagio, 7 - Carga/Descarga, 8 - Alimentacao
          AND notafiscalsimples_item.tipocombustivel = 1
          AND notafiscalsimples.dtemissao::DATE BETWEEN '{initialDate}' AND '{finalDate}'
          AND CASE
                  WHEN '' = '' THEN
                      TRUE
                  ELSE
                      notafiscalsimples.veiculo = ''
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto_subgrupo.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      produto.codigo = COALESCE('','')
              END
          AND CASE
                   WHEN COALESCE('Todas','') = '' THEN
                                TRUE
                  WHEN 'Todas' = 'Própria' THEN
                      veiculo.tipofrota = 1
                  WHEN 'Todas' = 'Agregada' THEN
                      veiculo.tipofrota = 3
                  WHEN 'Todas' = 'Terceira' THEN
                      veiculo.tipofrota = 2
                  WHEN 'Todas' = 'Todas' THEN
                      veiculo.tipofrota IN (1, 2, 3)
              END
          AND CASE
                  WHEN COALESCE(NULL,'') = '' THEN
                      TRUE
                  ELSE
                      veiculo.utilizacaoveiculo = COALESCE(NULL,'')
              END


      UNION ALL ---------------------  NOTA FISCAL ENTRADA NORMAL  ----


      SELECT
          DISTINCT
          notafiscalentrada.veiculo AS placa
          ,veiculo.numerofrota
          ,notafiscalentrada.grupo ||
           '-' || notafiscalentrada.empresa ||
           '-' || notafiscalentrada.filial ||
           '-' || notafiscalentrada.unidade AS gefu
          ,'NF Entrada'::VARCHAR AS tipodocumento
          ,'NF Entrada'::VARCHAR AS tipodoc
          ,notafiscalentrada.dtentrada::DATE AS dtentrada
          ,notafiscalentrada.dtemissao::DATE AS dtemissao
          ,0::INTEGER AS diferenciadornumero
          ,notafiscalentrada.serie AS serie
          ,notafiscalentrada.numero
          ,NULL::INTEGER AS numeroordemservico
          ,''::VARCHAR AS descricaodefeito
          ,''::VARCHAR AS complemento
          ,fornecedor.razaosocial AS fornecedornome
          ,produto.descricao
          ,produto.codigo AS codigoproduto
          ,grupoproduto.descricao AS grupoproduto
          ,grupoproduto_subgrupo.descricao AS subgrupoproduto
          ,notafiscalentrada_item.quantidade
          ,notafiscalentrada_item.valortotal
          ,CASE
                WHEN notafiscalentrada_item.basepara = 1 THEN
                    'Outros'
                WHEN notafiscalentrada_item.basepara = 4 THEN
                    'Lubrificantes'
                WHEN notafiscalentrada_item.basepara = 5 THEN
                    'Lavagem'
                ELSE
                    ''
          END AS basepara
          ,0::NUMERIC AS diasgarantia
          ,0::NUMERIC AS marcadorgarantia
          ,tipoveiculo.descricao AS tipoveiculo
          ,COALESCE(notafiscalentrada.marcador,0) AS km
          ,COALESCE(notafiscalentrada.marcadorrefrigeracao,0) AS horimetro
          ,''::VARCHAR AS observacao
          ,notafiscalentrada_item.sequencia
          ,NULL AS descricaoobjetivoos
          ,NULL::NUMERIC AS valortotalmaoobra
          ,NULL::NUMERIC AS valortotalpecas
          ,COALESCE(notafiscalentrada.diferencamarcador,0) AS diferencamarcador

      FROM notafiscalentrada_item

      JOIN notafiscalentrada
          ON  notafiscalentrada.empresa = notafiscalentrada_item.empresa
          AND notafiscalentrada.serie = notafiscalentrada_item.serie
          AND notafiscalentrada.numero = notafiscalentrada_item.numero
          AND notafiscalentrada.dtemissao = notafiscalentrada_item.dtemissao
          AND notafiscalentrada.cnpjcpfcodigo = notafiscalentrada_item.cnpjcpfcodigo

      LEFT JOIN notafiscalentrada_item_rateioveiculo
            ON  notafiscalentrada_item.grupo = notafiscalentrada_item_rateioveiculo.grupo
            AND notafiscalentrada_item.empresa = notafiscalentrada_item_rateioveiculo.empresa
            AND notafiscalentrada_item.cnpjcpfcodigo = notafiscalentrada_item_rateioveiculo.cnpjcpfcodigo
            AND notafiscalentrada_item.dtemissao = notafiscalentrada_item_rateioveiculo.dtemissao
            AND notafiscalentrada_item.serie = notafiscalentrada_item_rateioveiculo.serie
            AND notafiscalentrada_item.numero = notafiscalentrada_item_rateioveiculo.numero
            AND notafiscalentrada_item.sequencia = notafiscalentrada_item_rateioveiculo.sequencia

      LEFT JOIN cadastro fornecedor
          ON  fornecedor.codigo = notafiscalentrada.cnpjcpfcodigo

      LEFT JOIN produto
          ON  produto.codigo = notafiscalentrada_item.produto
          AND produto.grupo = notafiscalentrada_item.grupo
          AND produto.empresa = notafiscalentrada_item.empresa

      LEFT JOIN grupoproduto
          ON  grupoproduto.grupo = notafiscalentrada_item.grupo
          AND grupoproduto.empresa = notafiscalentrada_item.empresa
          AND grupoproduto.codigo = notafiscalentrada_item.grupoproduto

      LEFT JOIN grupoproduto_subgrupo
          ON  grupoproduto_subgrupo.grupo = notafiscalentrada_item.grupo
          AND grupoproduto_subgrupo.empresa = notafiscalentrada_item.empresa
          AND grupoproduto_subgrupo.grupoproduto = notafiscalentrada_item.grupoproduto
          AND grupoproduto_subgrupo.codigo = notafiscalentrada_item.subgrupoproduto

      JOIN veiculo
          ON  veiculo.placa = notafiscalentrada.veiculo

      LEFT JOIN tipoveiculo
          ON  tipoveiculo.codigo = veiculo.tipoveiculo


      WHERE
          notafiscalentrada.grupo = COALESCE(1,notafiscalentrada.grupo)
          AND notafiscalentrada.empresa = COALESCE(1,notafiscalentrada.empresa)
          AND notafiscalentrada.filial = COALESCE(NULL,notafiscalentrada.filial)
          AND notafiscalentrada.unidade = COALESCE(NULL,notafiscalentrada.unidade)
          AND notafiscalentrada.dtemissao BETWEEN '{initialDate}' AND '{finalDate}'
          AND CASE
                  WHEN '' = '' THEN
                      TRUE
                  ELSE
                      notafiscalentrada.veiculo = ''
              END
          AND notafiscalentrada_item.basepara IN (1, 4, 5) --1 - Outros, 2 - Abastecimento veiculo, 3 - Abastecimento refrigeracao, 4 - Lubrificantes, 5 - Lavagem, 6 - Pedagio, 7 - Carga/Descarga, 8 - Alimentacao
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      grupoproduto_subgrupo.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE('','') = '' THEN
                      TRUE
                  ELSE
                      produto.codigo = COALESCE('','')
              END
          AND CASE
                  WHEN COALESCE(notafiscalentrada_item_rateioveiculo.grupo, 0) > 0 THEN
                      notafiscalentrada_item_rateioveiculo.grupo = 0
                  ELSE
                      TRUE
              END
          AND CASE
                  WHEN COALESCE('Todas','') = '' THEN
                                TRUE
                  WHEN 'Todas' = 'Própria' THEN
                      veiculo.tipofrota = 1
                  WHEN 'Todas' = 'Agregada' THEN
                      veiculo.tipofrota = 3
                  WHEN 'Todas' = 'Terceira' THEN
                      veiculo.tipofrota = 2
                  WHEN 'Todas' = 'Todas' THEN
                      veiculo.tipofrota IN (1, 2, 3)
              END
          AND CASE
                  WHEN COALESCE(NULL,'') = '' THEN
                      TRUE
                  ELSE
                      veiculo.utilizacaoveiculo = COALESCE(NULL,'')
              END) AS q_retorno

WHERE
    CASE
        WHEN 'Todos' = 'Todos' THEN
            TRUE
        WHEN 'Todos' = 'NF Entrada' THEN
            q_retorno.tipodocumento = 'NF Entrada'
        WHEN 'Todos' = 'NF Entrada Rateio' THEN
            q_retorno.tipodocumento = 'NF Entrada Rateio'
        WHEN 'Todos' = 'Pneu' THEN
            q_retorno.tipodocumento = 'Pneu'
        WHEN 'Todos' = 'Ordem de Serviço' THEN
            q_retorno.tipodocumento = 'Ordem de Serviço'
        WHEN 'Todos' = 'NF Simplificada' THEN
            q_retorno.tipodocumento = 'NF Simplificada'
    END


ORDER BY
    q_retorno.placa
   ,q_retorno.numerofrota
   ,q_retorno.gefu
   ,q_retorno.dtentrada
   ,q_retorno.dtemissao
   ,q_retorno.tipodocumento
   ,q_retorno.diferenciadornumero
   ,q_retorno.serie
   ,q_retorno.numero
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
          , Count(tipoveiculo) "_Count_tipoveiculo"
          , Sum(valortotalmaoobra) "_Sum_valortotalmaoobra"
          , Sum(valortotalpecas) "_Sum_valortotalpecas"
          , Sum(quantidade) "_Sum_quantidade"
          , Sum(valortotal) "_Sum_valortotal"
       FROM q_filtered
   )
SELECT *
FROM q_filtered, q_totals