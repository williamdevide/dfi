WITH
   q_target AS
   (
-- Comando SQL original - INICIO
SELECT
	'' AS consultar	--será utilizado somente se a consulta não mostrar todos os campos, havendo necessidade de abrir um formulário para mostrar tudo
	,'' AS excluir
	,'' AS vincular
	,'' AS atualizarprocesso
	,'' AS legendatipoinclusao
	,'' AS legendaimprimedanfe
	,'' AS parcelascontasapagar
	,'' AS fluxocaixa
	,'' AS nfsimplificada
	,'' AS legendagerarcontaapagarcomposto
	,'' AS alterar
	,'' AS trocardados
	,'' AS legendasemaforo
	,'' AS legendafilialemissor
	,'' AS legendatipocte
	,'' AS legendaacerto
	,'' AS legendanfwms
	,notafiscalentrada.semaforo
	,notafiscalentrada.grupo
	,notafiscalentrada.empresa
	,notafiscalentrada.filial
	,notafiscalentrada.unidade
	,fnc_formata_cnpjcpfcod(notafiscalentrada.cnpjcpfcodigo) AS cnpjcpfcodigoformatado
	,initcap(cadastro.razaosocial) AS razaosocial
	,notafiscalentrada.cnpjcpfcodigo
	,notafiscalentrada.serie
	,serie.serie AS serieNF-- 200938
	,notafiscalentrada.numero
	,notafiscalentrada.dtemissao
	,notafiscalentrada.dtentrada
	,notafiscalentrada.valorprodutos
	,notafiscalentrada.valorservicos
	,notafiscalentrada.valortotalnotafiscal
	,notafiscalentrada.chaveacessonfe
	,notafiscalentrada.modelo
	,notafiscalentrada.tipoinclusao
	,notafiscalentrada.dtemissao::VARCHAR AS dataformatobanco
	,CASE
	 	WHEN COALESCE(notafiscalentrada.chaveacessonfe,'') <> '' THEN
	 		'comchave'
	 	ELSE
	 		'semchave'
	 END AS temchave

	 --88446
	,notafiscalentrada.processo AS processo

	,(CASE
	  	WHEN COALESCE(notafiscalentrada.gerarparcelas,0) = 1
	  		AND COALESCE(notafiscalentrada.gerarcontaapagarcomposto,0) = 1 THEN
	  		3 --PARA MUDAR A COR
	  	ELSE
	  		notafiscalentrada.gerarparcelas
	  END) AS gerarparcelas
	,CASE
	 	WHEN COALESCE(notafiscalentrada.valortotalnotafiscalsimples,0) > 0
	 		AND COALESCE(notafiscalentrada.valortotalnotafiscalsimples,0) <>

	 		    COALESCE((SELECT
	 		              	valor
	 		              FROM notafiscalentrada_valor

	 		              WHERE
	 		              	notafiscalentrada_valor.grupo = notafiscalentrada.grupo
	 		              	AND notafiscalentrada_valor.empresa = notafiscalentrada.empresa
	 		              	AND notafiscalentrada_valor.cnpjcpfcodigo = notafiscalentrada.cnpjcpfcodigo
	 		              	AND notafiscalentrada_valor.dtemissao = notafiscalentrada.dtemissao
	 		              	AND notafiscalentrada_valor.serie = notafiscalentrada.serie
	 		              	AND notafiscalentrada_valor.numero = notafiscalentrada.numero
	 		              	AND notafiscalentrada_valor.tipo = 110 --valor total
	 		              	    ),0) THEN
	 		1 --com divergencia
	 	WHEN COALESCE(notafiscalentrada.valortotalnotafiscalsimples,0) = 0 THEN
	 		3 --INCLUIR
	 	ELSE
	 		2 --sem divergencia
	 END AS divergenciavalortotalnotafiscalsimples
	,notafiscalentrada.gerarcontaapagarcomposto
	,CASE
		WHEN notafiscalentrada.cnpjcpfcodigocteorigem != xmldocumentoeletronico.cnpjcpfcodigopagador THEN
			1
		ELSE
			2
	END AS FilialUnidadeDiferenteDocumentoOrigem
	,xmldocumentoeletronico.tiposervicocte
	,CASE
		WHEN xmldocumentoeletronico.dtcancelamento IS NOT NULL THEN
			1
		ELSE
			2
		END AS xmlcancelado

	,notafiscalentrada.usuarioemissor
	,usuario.nomecompleto
	,notafiscalentrada.veiculo
	,CASE
	    WHEN notafiscalentrada.tiponotafiscal IN (7,8) THEN
	       1
	    ELSE
	       2
	 END AS nfwms
	 ,notafiscalentrada.tiponotafiscal
	 ,CASE WHEN notafiscalentrada.modelo IN ('57','67') THEN
        relatoriocte.nomerelatorio
        ELSE
        relatorio.nomerelatorio
        END as nomerelatorio
    ,CASE WHEN notafiscalentrada.modelo IN ('57','67') THEN
        relatoriocte.autor
        ELSE
        relatorio.autor
        END as autor
    ,CASE WHEN COALESCE(notafiscalentrada.chaveacessonfe,'') <> '' THEN 1 ELSE 2 END AS imprimedanfe
    ,('{"nome" : "Grupo", "valor" : "' || notafiscalentrada.Grupo::VARCHAR || '"}
       ,{"nome" : "Empresa", "valor" : "' || notafiscalentrada.Empresa::VARCHAR || '"}
       ,{"nome" : "Filial", "valor" : "' || notafiscalentrada.Filial::VARCHAR || '"}
       ,{"nome" : "ChaveAcesso", "valor" : "' || notafiscalentrada.chaveacessonfe::VARCHAR || '"}') AS Parametros

FROM notafiscalentrada

LEFT JOIN usuario ON usuario.codigo = notafiscalentrada.usuarioemissor

LEFT OUTER JOIN empresa_parametro
ON empresa_parametro.grupo = notafiscalentrada.grupo
AND empresa_parametro.empresa = notafiscalentrada.empresa
AND empresa_parametro.tipodocumento = 1

LEFT OUTER JOIN cadastro
	ON  cadastro.codigo = notafiscalentrada.cnpjcpfcodigo

LEFT JOIN serie
	ON notafiscalentrada.grupo = serie.grupo
	AND notafiscalentrada.empresa = serie.empresa
	AND notafiscalentrada.serie = serie.codigo

LEFT JOIN xmldocumentoeletronico
	ON xmldocumentoeletronico.chaveacesso = notafiscalentrada.chaveacessonfe

LEFT JOIN avacorpi.manifestacaodestinatario_parametro
    ON manifestacaodestinatario_parametro.grupo     = notafiscalentrada.grupo
    AND manifestacaodestinatario_parametro.empresa     = notafiscalentrada.empresa
    AND manifestacaodestinatario_parametro.filial    = notafiscalentrada.filial

LEFT JOIN arquivo.relatorio relatorio
    ON relatorio.nomerelatorio     = manifestacaodestinatario_parametro.nomeformulario
    AND relatorio.autor         = manifestacaodestinatario_parametro.autorformulario

LEFT JOIN arquivo.relatorio relatoriocte
    ON relatoriocte.nomerelatorio    = manifestacaodestinatario_parametro.nomeformulariocte
    AND relatoriocte.autor        = manifestacaodestinatario_parametro.autorformulariocte

WHERE
	notafiscalentrada.grupo = 1
	AND notafiscalentrada.empresa = 1
	AND CASE
	    	WHEN COALESCE(1,0) = 0 THEN
	    		TRUE
	    	ELSE
	    		notafiscalentrada.filial = 1
	    END
	AND CASE
	    	WHEN COALESCE(1,0) = 0 THEN
	    		TRUE
	    	ELSE
	    		notafiscalentrada.unidade = 1
	    END

	    --PARA VINCULADO ORDEM DE COMPRA NÃO FILTRAR POR DATA
	AND CASE
	    	WHEN COALESCE(2,0) IN (0, 3) THEN
	    		CASE
	    			WHEN 1 = 1 THEN
	    				--Emissão
	    				notafiscalentrada.dtemissao >= '{initialDate}'
	    				AND notafiscalentrada.dtemissao <= '{finalDate}'
	    			ELSE
	    				--Chegada
	    				notafiscalentrada.dtentrada >= '{initialDate}'
	    				AND notafiscalentrada.dtentrada <= '{finalDate}'
	    		END
	    	ELSE
	    		TRUE
	    END
	AND CASE
	    	WHEN COALESCE(2,0) = 0 THEN
	    		notafiscalentrada.processo IN (2, 3)
	    	ELSE
	    		notafiscalentrada.processo = 2
	    END
	AND CASE
	    	WHEN COALESCE(NULL,'') <> '' THEN
	    		notafiscalentrada.cnpjcpfcodigo = NULL
	    	ELSE
	    		TRUE
	    END
	AND (coalesce(0,0) = 0
		OR notafiscalentrada.numero = 0)
	AND (NULL IS NULL OR xmldocumentoeletronico.tiposervicocte = NULL)
	AND CASE
			WHEN COALESCE(NULL,0) = 1 THEN
				notafiscalentrada.cnpjcpfcodigocteorigem != xmldocumentoeletronico.cnpjcpfcodigopagador
			ELSE
				TRUE
		END
	AND CASE
			WHEN COALESCE(0,1) = 1 THEN
				xmldocumentoeletronico.dtcancelamento IS NOT NULL
			ELSE
				TRUE
		END
    AND NOT (COALESCE(notafiscalentrada.tiponotafiscal,0) IN (7,8) AND notafiscalentrada.armazemgeral = 2) -- NOTA WMS ARMAZENAGEM NÃO PODE APARECER, SOMENTE ARMAZÉM GERAL.
	AND CASE
			WHEN COALESCE(0,1) = 1 THEN
				TRUE
			ELSE
				/*despesas operacionais nao podem aparecer aqui*/
				 COALESCE((SELECT 1

					FROM notafiscalentrada_item_ordemcomprarecebida

					 JOIN despesaoperacional
					 ON despesaoperacional.grupo                     = notafiscalentrada.grupo
					 AND despesaoperacional.empresa	                 = notafiscalentrada.empresa
					 AND despesaoperacional.filialordemcompra        = notafiscalentrada_item_ordemcomprarecebida.filialordemcompra
					 AND despesaoperacional.unidadeordemcompra	     = notafiscalentrada_item_ordemcomprarecebida.unidadeordemcompra
					 AND despesaoperacional.diferenciadornumeroordemcompra = notafiscalentrada_item_ordemcomprarecebida.diferenciadornumeroordemcompra
					 AND despesaoperacional.numeroordemcompra        = notafiscalentrada_item_ordemcomprarecebida.numeroordemcompra
					 AND despesaoperacional.sequenciaitemordemcompra = notafiscalentrada_item_ordemcomprarecebida.sequenciaitemordemcompra

					 WHERE notafiscalentrada_item_ordemcomprarecebida.grupo =notafiscalentrada.grupo
					 AND notafiscalentrada_item_ordemcomprarecebida.empresa =notafiscalentrada.empresa
					 AND notafiscalentrada_item_ordemcomprarecebida.cnpjcpfcodigo =notafiscalentrada.cnpjcpfcodigo
					 AND notafiscalentrada_item_ordemcomprarecebida.dtemissao =notafiscalentrada.dtemissao
					 AND notafiscalentrada_item_ordemcomprarecebida.serie =notafiscalentrada.serie
					 AND notafiscalentrada_item_ordemcomprarecebida.numero =notafiscalentrada.numero
					 LIMIT 1),0) = 0


		END


ORDER BY
	notafiscalentrada.dtemissao DESC
   ,notafiscalentrada.dtentrada DESC
   ,notafiscalentrada.numero
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