WITH
   q_target AS
   (
-- Comando SQL original - INICIO
WITH qryNotaFiscalSimples AS (
    SELECT
        veiculo_marcador.veiculo
        ,veiculo_marcador.tipomarcador
        ,veiculo_marcador.dtdatabase
        ,notafiscalsimples.motorista
        ,notafiscalsimples.fornecedor AS cnpjcpfcodigo
        ,veiculo_marcador.tipodocumento
        ,item.produto_descricao AS item_produtodescricao
        ,item.valor AS item_valortotal
        ,item.valorunitario AS item_valorunitario
        ,notafiscalsimples.tanquecheio
        ,veiculo_marcador.marcador
        ,veiculo_marcador.marcadoranterior
        ,veiculo_marcador.diferencamarcador
        ,veiculo_marcador.semaforo
        ,veiculo_marcador.formacalculomedia
        ,veiculo_marcador.mediaconsumo
        ,CASE
             WHEN veiculo_marcador.tipomarcador = 1 THEN
                veiculo.mediaconsumofabrica
             WHEN veiculo_marcador.tipomarcador = 2 THEN
                veiculo.consumomdioarla
             WHEN veiculo_marcador.tipomarcador = 3 THEN
                veiculo.mediaconsumofabricarefrigeracao
             ELSE
                0
         END AS mediaconsumofabrica
        ,item.quantidade AS quantidadecombustivel
        ,veiculo_marcador.agrupador
        ,notafiscalsimples.grupo
        ,notafiscalsimples.empresa
        ,notafiscalsimples.filial
        ,notafiscalsimples.unidade
        ,notafiscalsimples.numero
        ,funcionarioresponsavel.razaosocial AS funcionarioresponsavel_razaosocial
        ,equipetiponegocio.descricao AS equipetiponegocio_descricao
        ,veiculo.centrocusto
        ,veiculo_marcador.idveiculomarcadoragrupamento

    FROM veiculo_marcador

    JOIN veiculo
        ON veiculo.placa = veiculo_marcador.veiculo

    JOIN notafiscalsimples
        ON notafiscalsimples.grupo = veiculo_marcador.grupo
        AND notafiscalsimples.empresa = veiculo_marcador.empresa
        AND notafiscalsimples.filial = veiculo_marcador.filial
        AND notafiscalsimples.unidade = veiculo_marcador.unidade
        AND notafiscalsimples.diferenciadorsequencia = veiculo_marcador.diferenciadornumero
        AND notafiscalsimples.sequencia = veiculo_marcador.numero
        AND notafiscalsimples.tipodocumento = veiculo_marcador.tipodocumento

    LEFT JOIN LATERAL
    (
        SELECT
            STRING_AGG(DISTINCT produto.descricao, ',') produto_descricao
            ,SUM(COALESCE(notafiscalsimples_item.valortotalmoedautilizada,0) - COALESCE(notafiscalsimples_item.valordescontomoedautilizada,0)) AS valor
            ,(SUM(notafiscalsimples_item.valorunitariomoedautilizada) / COUNT(notafiscalsimples_item.*)) AS valorunitario
            ,SUM(notafiscalsimples_item.quantidade) AS quantidade
            ,notafiscalsimples_item.sequencia
        FROM notafiscalsimples_item

        JOIN produto
            ON produto.grupo = notafiscalsimples_item.grupo
            AND produto.empresa = notafiscalsimples_item.empresa
            AND produto.codigo = notafiscalsimples_item.produto

        WHERE
            notafiscalsimples_item.grupo = notafiscalsimples.grupo
            AND notafiscalsimples_item.empresa = notafiscalsimples.empresa
            AND notafiscalsimples_item.filial = notafiscalsimples.filial
            AND notafiscalsimples_item.unidade = notafiscalsimples.unidade
            AND notafiscalsimples_item.diferenciadorsequencia = notafiscalsimples.diferenciadorsequencia
            AND notafiscalsimples_item.sequencia = notafiscalsimples.sequencia
            AND CASE
                    WHEN veiculo_marcador.tipomarcador = 1 THEN
                        notafiscalsimples_item.basepara = 2
                        AND notafiscalsimples_item.tipocombustivel IN (2,3,5)
                    WHEN veiculo_marcador.tipomarcador = 2 THEN
                        notafiscalsimples_item.basepara = 2
                        AND notafiscalsimples_item.tipocombustivel IN (9)
                    WHEN veiculo_marcador.tipomarcador = 3 THEN
                        notafiscalsimples_item.basepara = 3
                 END
        GROUP BY notafiscalsimples_item.sequencia,produto.descricao
    ) AS item
    ON TRUE

    LEFT JOIN cadastro AS funcionarioresponsavel
        ON funcionarioresponsavel.codigo = veiculo.funcionarioresponsavel

    LEFT JOIN LATERAL
    (
        SELECT
            STRING_AGG(equipetiponegocio.descricao,', ') AS descricao
        FROM usuario

        JOIN equipetiponegocio_participantes
            ON equipetiponegocio_participantes.usuario = usuario.codigo

        JOIN equipetiponegocio
            ON equipetiponegocio.id = equipetiponegocio_participantes.idequipetiponegocio

        WHERE
            usuario.cnpjcpfcodigoausuarioexterno = veiculo.funcionarioresponsavel
            AND (COALESCE(NULL,0) = 0 OR equipetiponegocio.id = NULL)
    ) AS equipetiponegocio
    ON TRUE

    WHERE
        veiculo_marcador.tipomarcador IN (1,2,3)
        AND veiculo_marcador.tipodocumento = 30
        AND veiculo_marcador.agrupador = 2
        AND (COALESCE(1,0) = 0 OR  veiculo_marcador.grupo = 1)
        AND (COALESCE(1,0) = 0 OR  veiculo_marcador.empresa = 1)
        AND (COALESCE(NULL,0) = 0 OR notafiscalsimples.filial = NULL)
        AND (COALESCE(NULL,0) = 0 OR notafiscalsimples.unidade = NULL)
        AND veiculo_marcador.dtdatabase::DATE BETWEEN '{initialDate}' AND '{finalDate}'
        AND (COALESCE('','') = '' OR notafiscalsimples.fornecedor = avacorpi.fnc_desformata_cnpjcpf(''))
        AND (COALESCE('','') = '' OR veiculo_marcador.veiculo = UPPER(''))
        AND (CASE WHEN 'Todos' = 'Própria' THEN
                                     veiculo.tipofrota = 1
                               WHEN 'Todos' = 'Terceiro' THEN
                                    veiculo.tipofrota = 2
                               WHEN 'Todos' = 'Agregado' THEN
                                    veiculo.tipofrota = 3
                               ELSE
                                   TRUE
                               END)
        AND CASE UPPER('TODOS')
                WHEN 'TODOS' THEN
                    TRUE
                WHEN 'ABASTECIMENTO' THEN
                    veiculo_marcador.tipomarcador = 1
                WHEN 'REAGENTE' THEN
                    veiculo_marcador.tipomarcador = 2
                WHEN 'REFRIGERACAO' THEN
                    veiculo_marcador.tipomarcador = 3
             END
      AND UPPER('AMBOS') IN ('AMBOS','EXTERNO')
      AND (COALESCE('','') = '' OR veiculo.funcionarioresponsavel = avacorpi.fnc_desformata_cnpjcpf(''))
      AND (COALESCE('','') = '' OR veiculo.caracteristicaveiculo = '')
      AND (COALESCE(NULL,0) = 0 OR equipetiponegocio.descricao IS NOT NULL)

), qryAbastecimentoInterno AS (
    SELECT
        veiculo_marcador.veiculo
        ,veiculo_marcador.tipomarcador
        ,veiculo_marcador.dtdatabase
        ,notafiscalsimples.motorista
        ,notafiscalsimples.fornecedor AS cnpjcpfcodigo
        ,veiculo_marcador.tipodocumento
        ,item.produto_descricao AS item_produtodescricao
        ,item.valor AS item_valortotal
        ,item.valorunitario AS item_valorunitario
        ,notafiscalsimples.tanquecheio
        ,veiculo_marcador.marcador
        ,veiculo_marcador.marcadoranterior
        ,veiculo_marcador.diferencamarcador
        ,veiculo_marcador.semaforo
        ,veiculo_marcador.formacalculomedia
        ,veiculo_marcador.mediaconsumo
        ,CASE
             WHEN veiculo_marcador.tipomarcador = 1 THEN
                veiculo.mediaconsumofabrica
             WHEN veiculo_marcador.tipomarcador = 2 THEN
                veiculo.consumomdioarla
             WHEN veiculo_marcador.tipomarcador = 3 THEN
                veiculo.mediaconsumofabricarefrigeracao
             ELSE
                0
         END AS mediaconsumofabrica
        ,item.quantidade AS quantidadecombustivel
        ,veiculo_marcador.agrupador
        ,notafiscalsimples.grupo
        ,notafiscalsimples.empresa
        ,notafiscalsimples.filial
        ,notafiscalsimples.unidade
        ,notafiscalsimples.numero
        ,funcionarioresponsavel.razaosocial AS funcionarioresponsavel_razaosocial
        ,equipetiponegocio.descricao AS equipetiponegocio_descricao
        ,veiculo.centrocusto
        ,veiculo_marcador.idveiculomarcadoragrupamento

    FROM veiculo_marcador

    JOIN veiculo
        ON veiculo.placa = veiculo_marcador.veiculo

    JOIN notafiscalsimples
        ON notafiscalsimples.grupo = veiculo_marcador.grupo
        AND notafiscalsimples.empresa = veiculo_marcador.empresa
        AND notafiscalsimples.filial = veiculo_marcador.filial
        AND notafiscalsimples.unidade = veiculo_marcador.unidade
        AND notafiscalsimples.diferenciadorsequencia = veiculo_marcador.diferenciadornumero
        AND notafiscalsimples.sequencia = veiculo_marcador.numero
        AND notafiscalsimples.tipodocumento = veiculo_marcador.tipodocumento

    LEFT JOIN LATERAL
    (
        SELECT
           STRING_AGG(DISTINCT produto.descricao, ',') produto_descricao
           ,SUM(COALESCE(notafiscalsimples_item.valortotal,0) - COALESCE(notafiscalsimples_item.valordesconto,0)) AS valor
           ,(SUM(notafiscalsimples_item.valorunitario) / COUNT(notafiscalsimples_item.*)) AS valorunitario
           ,SUM(notafiscalsimples_item.quantidade) AS quantidade
           ,notafiscalsimples_item.sequencia
        FROM notafiscalsimples_item

        JOIN produto
            ON produto.grupo = notafiscalsimples_item.grupo
            AND produto.empresa = notafiscalsimples_item.empresa
            AND produto.codigo = notafiscalsimples_item.produto

        WHERE
            notafiscalsimples_item.grupo = notafiscalsimples.grupo
            AND notafiscalsimples_item.empresa = notafiscalsimples.empresa
            AND notafiscalsimples_item.filial = notafiscalsimples.filial
            AND notafiscalsimples_item.unidade = notafiscalsimples.unidade
            AND notafiscalsimples_item.diferenciadorsequencia = notafiscalsimples.diferenciadorsequencia
            AND notafiscalsimples_item.sequencia = notafiscalsimples.sequencia
            AND CASE
                    WHEN veiculo_marcador.tipomarcador = 1 THEN
                        notafiscalsimples_item.basepara = 2
                        AND notafiscalsimples_item.tipocombustivel IN (2,3,5)
                    WHEN veiculo_marcador.tipomarcador = 2 THEN
                        notafiscalsimples_item.basepara = 2
                        AND notafiscalsimples_item.tipocombustivel IN (9)
                    WHEN veiculo_marcador.tipomarcador = 3 THEN
                        notafiscalsimples_item.basepara = 3
                 END
         GROUP BY notafiscalsimples_item.sequencia,produto.descricao

    ) AS item
    ON TRUE

    LEFT JOIN cadastro AS funcionarioresponsavel
        ON funcionarioresponsavel.codigo = veiculo.funcionarioresponsavel

    LEFT JOIN LATERAL
    (
        SELECT
            STRING_AGG(equipetiponegocio.descricao,', ') AS descricao
        FROM usuario

        JOIN equipetiponegocio_participantes
            ON equipetiponegocio_participantes.usuario = usuario.codigo

        JOIN equipetiponegocio
            ON equipetiponegocio.id = equipetiponegocio_participantes.idequipetiponegocio

        WHERE
            usuario.cnpjcpfcodigoausuarioexterno = veiculo.funcionarioresponsavel
            AND (COALESCE(NULL,0) = 0 OR equipetiponegocio.id = NULL)
    ) AS equipetiponegocio
    ON TRUE

    WHERE
        veiculo_marcador.tipomarcador IN (1,2,3)
        AND veiculo_marcador.tipodocumento = 31
        AND veiculo_marcador.agrupador = 2
        AND (COALESCE(1,0) = 0 OR veiculo_marcador.grupo = 1)
        AND (COALESCE(1,0) = 0 OR veiculo_marcador.empresa = 1)
        AND (COALESCE(NULL,0) = 0 OR notafiscalsimples.filial = NULL)
        AND (COALESCE(NULL,0) = 0 OR notafiscalsimples.unidade = NULL)
        AND veiculo_marcador.dtdatabase::DATE BETWEEN '{initialDate}' AND '{finalDate}'
        AND (COALESCE('','') = '' OR notafiscalsimples.fornecedor = avacorpi.fnc_desformata_cnpjcpf(''))
        AND (COALESCE('','') = '' OR veiculo_marcador.veiculo = UPPER(''))
        AND (CASE WHEN 'Todos' = 'Própria' THEN
                                     veiculo.tipofrota = 1
                               WHEN 'Todos' = 'Terceiro' THEN
                                    veiculo.tipofrota = 2
                               WHEN 'Todos' = 'Agregado' THEN
                                    veiculo.tipofrota = 3
                               ELSE
                                   TRUE
                               END)
        AND CASE UPPER('TODOS')
                WHEN 'TODOS' THEN
                    TRUE
                WHEN 'ABASTECIMENTO' THEN
                    veiculo_marcador.tipomarcador = 1
                WHEN 'REAGENTE' THEN
                    veiculo_marcador.tipomarcador = 2
                WHEN 'REFRIGERACAO' THEN
                    veiculo_marcador.tipomarcador = 3
             END
        AND UPPER('AMBOS') IN ('AMBOS','INTERNO')
        AND (COALESCE('','') = '' OR veiculo.funcionarioresponsavel = avacorpi.fnc_desformata_cnpjcpf(''))
        AND (COALESCE('','') = '' OR veiculo.caracteristicaveiculo = '')
        AND (COALESCE(NULL,0) = 0 OR equipetiponegocio.descricao IS NOT NULL)

), qryNotaFiscal AS (
    SELECT
        veiculo_marcador.veiculo
        ,veiculo_marcador.tipomarcador
        ,veiculo_marcador.dtdatabase
        ,notafiscalentrada.motorista
        ,notafiscalentrada.cnpjcpfcodigo
        ,veiculo_marcador.tipodocumento
        ,item.produto_descricao AS item_produtodescricao
        ,item.valor AS item_valortotal
        ,item.valorunitario AS item_valorunitario
        ,2::INT AS tanquecheio
        ,veiculo_marcador.marcador
        ,veiculo_marcador.marcadoranterior
        ,veiculo_marcador.diferencamarcador
        ,veiculo_marcador.semaforo
        ,veiculo_marcador.formacalculomedia
        ,veiculo_marcador.mediaconsumo
        ,CASE
             WHEN veiculo_marcador.tipomarcador = 1 THEN
                veiculo.mediaconsumofabrica
             WHEN veiculo_marcador.tipomarcador = 2 THEN
                veiculo.consumomdioarla
             WHEN veiculo_marcador.tipomarcador = 3 THEN
                veiculo.mediaconsumofabricarefrigeracao
             ELSE
                0
         END AS mediaconsumofabrica
        ,item.quantidade AS quantidadecombustivel
        ,veiculo_marcador.agrupador
        ,notafiscalentrada.grupo
        ,notafiscalentrada.empresa
        ,notafiscalentrada.filial
        ,notafiscalentrada.unidade
        ,notafiscalentrada.numero
        ,funcionarioresponsavel.razaosocial AS funcionarioresponsavel_razaosocial
        ,equipetiponegocio.descricao AS equipetiponegocio_descricao
        ,veiculo.centrocusto
        ,veiculo_marcador.idveiculomarcadoragrupamento

    FROM veiculo_marcador

    JOIN veiculo
        ON veiculo.placa = veiculo_marcador.veiculo

    JOIN notafiscalentrada
        ON notafiscalentrada.grupo = veiculo_marcador.grupo
        AND notafiscalentrada.empresa = veiculo_marcador.empresa
        AND notafiscalentrada.cnpjcpfcodigo = veiculo_marcador.cnpjcpfcodigo
        AND notafiscalentrada.dtemissao = veiculo_marcador.dtemissao
        AND notafiscalentrada.serie = veiculo_marcador.serie
        AND notafiscalentrada.numero = veiculo_marcador.numero

    LEFT JOIN LATERAL
    (
        SELECT
            STRING_AGG(DISTINCT produto.descricao, ',') produto_descricao
            ,SUM(COALESCE(notafiscalentrada_item.valorprodutos,0) - COALESCE(notafiscalentrada_item.valortotaldesconto,0)) AS valor
            ,(SUM(notafiscalentrada_item.valorunitario) / COUNT(notafiscalentrada_item.*)) AS valorunitario
            ,SUM(notafiscalentrada_item.quantidade) AS quantidade
            ,notafiscalentrada_item.numero
        FROM notafiscalentrada_item

        JOIN produto
            ON produto.grupo = notafiscalentrada_item.grupo
            AND produto.empresa = notafiscalentrada_item.empresa
            AND produto.codigo = notafiscalentrada_item.produto

        WHERE
            notafiscalentrada_item.grupo = notafiscalentrada.grupo
            AND notafiscalentrada_item.empresa = notafiscalentrada.empresa
            AND notafiscalentrada_item.cnpjcpfcodigo = notafiscalentrada.cnpjcpfcodigo
            AND notafiscalentrada_item.dtemissao = notafiscalentrada.dtemissao
            AND notafiscalentrada_item.serie = notafiscalentrada.serie
            AND notafiscalentrada_item.numero = notafiscalentrada.numero
            AND CASE
                    WHEN veiculo_marcador.tipomarcador = 1 THEN
                        notafiscalentrada_item.basepara = 2
                        AND notafiscalentrada_item.tipocombustivel IN (2,3,5)
                    WHEN veiculo_marcador.tipomarcador = 2 THEN
                        notafiscalentrada_item.basepara = 2
                        AND notafiscalentrada_item.tipocombustivel IN (9)
                    WHEN veiculo_marcador.tipomarcador = 3 THEN
                        notafiscalentrada_item.basepara = 3
                 END
        GROUP BY notafiscalentrada_item.numero,produto.descricao
    ) AS item
    ON TRUE

    LEFT JOIN cadastro AS funcionarioresponsavel
        ON funcionarioresponsavel.codigo = veiculo.funcionarioresponsavel

    LEFT JOIN LATERAL
    (
        SELECT
            STRING_AGG(equipetiponegocio.descricao,', ') AS descricao
        FROM usuario

        JOIN equipetiponegocio_participantes
            ON equipetiponegocio_participantes.usuario = usuario.codigo

        JOIN equipetiponegocio
            ON equipetiponegocio.id = equipetiponegocio_participantes.idequipetiponegocio

        WHERE
            usuario.cnpjcpfcodigoausuarioexterno = veiculo.funcionarioresponsavel
            AND (COALESCE(NULL,0) = 0 OR equipetiponegocio.id = NULL)
    ) AS equipetiponegocio
    ON TRUE

    WHERE
        veiculo_marcador.tipomarcador IN (1,2,3)
        AND veiculo_marcador.tipodocumento = 1
        AND veiculo_marcador.agrupador = 2
        AND (COALESCE(1,0) = 0 OR veiculo_marcador.grupo = 1)
        AND (COALESCE(1,0) = 0 OR veiculo_marcador.empresa = 1)
        AND (COALESCE(NULL,0) = 0 OR notafiscalentrada.filial = NULL)
        AND (COALESCE(NULL,0) = 0 OR notafiscalentrada.unidade = NULL)
        AND veiculo_marcador.dtdatabase::DATE BETWEEN '{initialDate}' AND '{finalDate}'
        AND (COALESCE('','') = '' OR notafiscalentrada.cnpjcpfcodigo = avacorpi.fnc_desformata_cnpjcpf(''))
        AND (COALESCE('','') = '' OR veiculo_marcador.veiculo = UPPER(''))
        AND (CASE WHEN 'Todos' = 'Própria' THEN
                                     veiculo.tipofrota = 1
                               WHEN 'Todos' = 'Terceiro' THEN
                                    veiculo.tipofrota = 2
                               WHEN 'Todos' = 'Agregado' THEN
                                    veiculo.tipofrota = 3
                               ELSE
                                   TRUE
                               END)
        AND CASE UPPER('TODOS')
                WHEN 'TODOS' THEN
                    TRUE
                WHEN 'ABASTECIMENTO' THEN
                    veiculo_marcador.tipomarcador = 1
                WHEN 'REAGENTE' THEN
                    veiculo_marcador.tipomarcador = 2
                WHEN 'REFRIGERACAO' THEN
                    veiculo_marcador.tipomarcador = 3
             END
        AND UPPER('AMBOS') IN ('AMBOS','EXTERNO')
        AND (COALESCE('','') = '' OR veiculo.funcionarioresponsavel = avacorpi.fnc_desformata_cnpjcpf(''))
        AND (COALESCE('','') = '' OR veiculo.caracteristicaveiculo = '')
        AND (COALESCE(NULL,0) = 0 OR equipetiponegocio.descricao IS NOT NULL)

), qryDocs AS (
    SELECT
        *
    FROM qryNotaFiscalSimples
    UNION ALL
    SELECT
        *
    FROM qryAbastecimentoInterno
    UNION ALL
    SELECT
        *
    FROM qryNotaFiscal

), qryAgrupador AS (
    SELECT
        veiculo_marcador.veiculo
        ,veiculo_marcador.tipomarcador
        ,veiculo_marcador.dtdatabase
        ,item.motorista
        ,item.cnpjcpfcodigo
        ,veiculo_marcador.tipodocumento
        ,item.item_produtodescricao
        ,itemsoma.item_valortotal
        ,item.item_valorunitario
        ,item.tanquecheio
        ,veiculo_marcador.marcador
        ,veiculo_marcador.marcadoranterior
        ,veiculo_marcador.diferencamarcador
        ,veiculo_marcador.semaforo
        ,veiculo_marcador.formacalculomedia
        ,veiculo_marcador.mediaconsumo
        ,CASE
             WHEN veiculo_marcador.tipomarcador = 1 THEN
                veiculo.mediaconsumofabrica
             WHEN veiculo_marcador.tipomarcador = 2 THEN
                veiculo.consumomdioarla
             WHEN veiculo_marcador.tipomarcador = 3 THEN
                veiculo.mediaconsumofabricarefrigeracao
             ELSE
                0
         END AS mediaconsumofabrica
        ,veiculo_marcador.quantidadecombustivel
        ,veiculo_marcador.agrupador
        ,veiculo_marcador.grupo
        ,veiculo_marcador.empresa
        ,veiculo_marcador.filial
        ,veiculo_marcador.unidade
        ,veiculo_marcador.numero
        ,funcionarioresponsavel.razaosocial AS funcionarioresponsavel_razaosocial
        ,equipetiponegocio.descricao AS equipetiponegocio_descricao
        ,veiculo.centrocusto
        ,veiculo_marcador.idveiculomarcadoragrupamento

   FROM veiculo_marcador

   JOIN veiculo
       ON veiculo.placa = veiculo_marcador.veiculo

   JOIN LATERAL
   (
       SELECT
           qryDocs.item_produtodescricao
           ,qryDocs.motorista
           ,qryDocs.cnpjcpfcodigo
           ,qryDocs.tanquecheio
           ,qryDocs.item_valorunitario
       FROM qryDocs
       WHERE
           qryDocs.idveiculomarcadoragrupamento = veiculo_marcador.id
       LIMIT
           1
   ) AS item
   ON TRUE

   JOIN LATERAL
   (
       SELECT
           SUM(qryDocs.item_valortotal) AS item_valortotal
       FROM qryDocs
       WHERE
           qryDocs.idveiculomarcadoragrupamento = veiculo_marcador.id
   ) AS itemsoma
   ON TRUE

   LEFT JOIN cadastro AS funcionarioresponsavel
       ON funcionarioresponsavel.codigo = veiculo.funcionarioresponsavel

   LEFT JOIN LATERAL
   (
       SELECT
           STRING_AGG(equipetiponegocio.descricao,', ') AS descricao
       FROM usuario

       JOIN equipetiponegocio_participantes
           ON equipetiponegocio_participantes.usuario = usuario.codigo

       JOIN equipetiponegocio
           ON equipetiponegocio.id = equipetiponegocio_participantes.idequipetiponegocio

       WHERE
           usuario.cnpjcpfcodigoausuarioexterno = veiculo.funcionarioresponsavel
           AND (COALESCE(NULL,0) = 0 OR equipetiponegocio.id = NULL)
   ) AS equipetiponegocio
   ON TRUE

   WHERE
       veiculo_marcador.tipomarcador = 1
       AND veiculo_marcador.agrupador = 1
       AND (COALESCE(1,0) = 0 OR veiculo_marcador.grupo = 1)
       AND (COALESCE(1,0) = 0 OR veiculo_marcador.empresa = 1)
       AND veiculo_marcador.dtdatabase::DATE BETWEEN '{initialDate}' AND '{finalDate}'
       AND (COALESCE('','') = '' OR veiculo_marcador.veiculo = UPPER(''))
       AND (CASE
                WHEN 'Todos' = 'Própria' THEN
                     veiculo.tipofrota = 1
                WHEN 'Todos' = 'Terceiro' THEN
                    veiculo.tipofrota = 2
                WHEN 'Todos' = 'Agregado' THEN
                    veiculo.tipofrota = 3
                ELSE
                   TRUE
                END)
       AND CASE UPPER('TODOS')
              WHEN 'TODOS' THEN
                   TRUE
               WHEN 'ABASTECIMENTO' THEN
                   veiculo_marcador.tipomarcador = 1
               ELSE
                   FALSE
            END
     AND (COALESCE('','') = '' OR veiculo.funcionarioresponsavel = avacorpi.fnc_desformata_cnpjcpf(''))
     AND (COALESCE('','') = '' OR veiculo.caracteristicaveiculo = '')
     AND (COALESCE(NULL,0) = 0 OR equipetiponegocio.descricao IS NOT NULL)
), qryTodos AS (
    SELECT
        *
    FROM qryDocs
    WHERE
        qryDocs.idveiculomarcadoragrupamento IS NULL
    UNION ALL
    SELECT
        *
    FROM qryAgrupador
)
SELECT
    qryTodos.veiculo
    ,CASE qryTodos.semaforo
        WHEN 0 THEN
            'Erro'
        ELSE
            'Ok'
     END AS registro
    ,qryTodos.dtdatabase AS dataabastecimento
    ,qryTodos.item_produtodescricao
    ,qryTodos.item_valortotal
   --  ,(COALESCE(qryTodos.item_valortotal,0) // COALESCE(qryTodos.quantidadecombustivel,0)) AS item_valorunitario
    ,COALESCE(qryTodos.item_valorunitario,0) AS item_valorunitario
    ,CASE qryTodos.tipomarcador
        WHEN 1 THEN
            'Abastecimento'
        WHEN 2 THEN
            'Reagente'
        WHEN 3 THEN
            'Refrigeração'
     END AS tipomarcador_descricao
    ,motorista.razaosocial AS motorista_razaosocial
    ,fornecedor.razaosocial AS fornecedor_razaosocial
    ,avacorpi.fnc_formata_cnpjcpf(fornecedor.codigo) AS fornecedor_codigo
    ,fornecedor.cidade AS fornecedor_cidade
    ,fornecedor.uf AS fornecedor_uf
    ,CASE qryTodos.tanquecheio
        WHEN 1 THEN
            'Sim'
        ELSE
            'Não'
     END AS tanquecheio
    ,CASE qryTodos.agrupador
        WHEN 1 THEN
            'Sim'
        ELSE
            ''
     END AS agrupado
    ,qryTodos.marcador
    ,qryTodos.marcadoranterior
    ,qryTodos.diferencamarcador
    ,qryTodos.quantidadecombustivel
    ,qryTodos.mediaconsumo
    ,qryTodos.mediaconsumofabrica -- adicionado 13-05-2022
    ,CASE COALESCE(qryTodos.formacalculomedia,0)
        WHEN 1 THEN
            'KM/L'
        WHEN 2 THEN
            'HR/L'
        WHEN 3 THEN
            'L/HR'
        WHEN 4 THEN
            'HR/M3'
        WHEN 5 THEN
            'M3/HR'
        WHEN 6 THEN
            'KM/M3'
        WHEN 7 THEN
            'KM/KW'
        ELSE
            ''
     END AS formacalculomedia_descricao
    ,tipodocumento.identificacaolivrofiscal AS tipodocumento
    ,(unidade.filial || '/' ||unidade.codigo||' - '||unidade.descricao) AS unidade_descricao
    ,qryTodos.numero
    ,(centrocusto.codigo || ' - ' || centrocusto.descricao) AS centrocusto_descricao
    ,qryTodos.funcionarioresponsavel_razaosocial
    ,qryTodos.equipetiponegocio_descricao

FROM qryTodos

JOIN tipodocumento
    ON tipodocumento.codigo = qryTodos.tipodocumento

LEFT JOIN unidade
    ON unidade.grupo = qryTodos.grupo
    AND unidade.empresa = qryTodos.empresa
    AND unidade.filial = qryTodos.filial
    AND unidade.codigo = qryTodos.unidade

LEFT JOIN cadastro AS motorista
    ON motorista.codigo = qryTodos.motorista

LEFT JOIN cadastro AS fornecedor
    ON fornecedor.codigo = qryTodos.cnpjcpfcodigo

LEFT JOIN centrocusto
    ON centrocusto.grupo = qryTodos.grupo
    AND centrocusto.codigo = qryTodos.centrocusto

ORDER BY
    qryTodos.dtdatabase DESC
    ,qryTodos.marcador DESC
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
          , Sum(marcador) "_Sum_marcador"
          , Sum(marcadoranterior) "_Sum_marcadoranterior"
          , Sum(diferencamarcador) "_Sum_diferencamarcador"
          , Sum(quantidadecombustivel) "_Sum_quantidadecombustivel"
          , Avg(mediaconsumofabrica) "_Avg_mediaconsumofabrica"
          , Avg(item_valorunitario) "_Avg_item_valorunitario"
          , Sum(item_valortotal) "_Sum_item_valortotal"
       FROM q_filtered
   )
SELECT *
FROM q_filtered, q_totals