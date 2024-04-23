With tFluxo as (
SELECT
                retorno.tipofluxo
                ,retorno.grupofluxo
                ,retorno.subgrupofluxo
                ,retorno.descricaofluxo
                ,retorno.datafluxo
                ,retorno.valor
                ,retorno.origemdados
                ,retorno.clientefornecedor
                ,retorno.tipotitulo
            FROM avacorpi.fnc_relatorio_fluxocaixa_realizado_m2(1::INT    --pnGrupo
                    ,COALESCE(1,0)::INT    --pnEmpresa
                    ,'{initialDate}'::DATE    --pdDataInicial
                    ,'{finalDate}'::DATE    --pdDataFinal
                    ,'EMISSAO'::VARCHAR    --pcFiltrarPorData
                    ,COALESCE(0,0)::NUMERIC    --pnSaldoInicial
                    ,'Sim'::VARCHAR    --pcConsiderarSaldoBancos
                    ,'Sim'::VARCHAR    --pcConsiderarSaldoCaixa
                    ,'Não'::VARCHAR    --pcFiltrarNaoFaturados
                    ,'Não'::VARCHAR    --pcEntradasVencidas
                    ,NULL::VARCHAR    -- pcCalcularPrevisao
                    ,'Não'::VARCHAR    --pcFiltrarSaidas
                    ,'Sim'::VARCHAR    --pcFiltrarCheques
                    ,'Sim'::VARCHAR    --pcConsiderarOrdemCompra
                    ,NULL::VARCHAR[] -- pcDocumentos
                     ) AS retorno
)

/* ******************************************
 * Fluxo de Caixa
 ****************************************** */
SELECT
	retorno.tipofluxo
	,retorno.grupofluxo
	,retorno.subgrupofluxo
	,retorno.descricaofluxo
	,retorno.datafluxo AS DATA
	,CASE
	 	WHEN retorno.tipofluxo = '0. Saldo Inicial' THEN
	 		CASE
	 			WHEN retorno.datafluxo = (CASE EXTRACT(DOW FROM '{initialDate}'::DATE)
	 			                          	WHEN 0 THEN
	 			                          		'{initialDate}'::DATE + 1
	 			                          	WHEN 6 THEN
	 			                          		'{initialDate}'::DATE + 2
	 			                          	ELSE
	 			                          		'{initialDate}'::DATE
	 			                          END) THEN
	 				retorno.valor
	 			ELSE
	 				SUM(retorno.valor) OVER(ORDER BY retorno.datafluxo
	 				   ,retorno.tipofluxo ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	 		END
	 	ELSE
	 		retorno.valor
	 END AS valor
	,retorno.origemdados
	,retorno.clientefornecedor
	,retorno.tipotitulo
FROM tFluxo AS retorno

UNION ALL
/* ******************************************
 * Saldo Final do Dia
 ****************************************** */
SELECT
	'6. Saldo Final'::VARCHAR AS tipofluxo
	,'1. Saldo do Dia'::VARCHAR AS grupofluxo
	,'1. Saldo do Dia'::VARCHAR AS subgrupofluxo
	,'1. Saldo'::VARCHAR AS descricaofluxo
	,retorno.datafluxo AS DATA
	,SUM(retorno.valor) AS valor
	,'Saldodofinal'::VARCHAR AS origemdados
	,NULL AS clientefornecedor
	,NULL AS tipotitulo
FROM (SELECT
      	retorno.datafluxo
      	,CASE
      	 	WHEN retorno.tipofluxo = '0. Saldo Inicial' THEN
      	 		CASE
      	 			WHEN retorno.datafluxo = (CASE EXTRACT(DOW FROM '{initialDate}'::DATE)
      	 			                          	WHEN 0 THEN
      	 			                          		'{initialDate}'::DATE + 1
      	 			                          	WHEN 6 THEN
      	 			                          		'{initialDate}'::DATE + 2
      	 			                          	ELSE
      	 			                          		'{initialDate}'::DATE
      	 			                          END) THEN
      	 				-- Data Inicial
      	 				retorno.valor
      	 			ELSE
      	 				SUM(retorno.valor) OVER(ORDER BY retorno.datafluxo
      	 				   ,retorno.tipofluxo ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
      	 		END
      	 	ELSE
      	 		retorno.valor
      	 END AS valor
      FROM tFluxo AS retorno) AS retorno

GROUP BY
	retorno.datafluxo

UNION ALL
/* ******************************************
 * Saldo Operacional do Dia
 ****************************************** */
SELECT
	'7. Saldo Operacional'::VARCHAR AS tipofluxo
	,'1. Saldo Operacional'::VARCHAR AS grupofluxo
	,'1. Saldo Operacional'::VARCHAR AS subgrupofluxo
	,'1. Saldo'::VARCHAR AS descricaofluxo
	,retorno.datafluxo AS DATA
	,SUM(retorno.valor) AS valor
	,'Saldodofinal'::VARCHAR AS origemdados
	,NULL AS clientefornecedor
	,NULL AS tipotitulo
FROM (SELECT
      	retorno.tipofluxo
      	,retorno.grupofluxo
      	,retorno.subgrupofluxo
      	,retorno.descricaofluxo
      	,retorno.datafluxo
      	,retorno.valor
      	,retorno.origemdados
      	,retorno.clientefornecedor
      	,retorno.tipotitulo
      FROM avacorpi.fnc_relatorio_fluxocaixa_realizado_m2(1::INT	--pnGrupo
              ,COALESCE(1,0)::INT	--pnEmpresa
              ,'{initialDate}'::DATE	--pdDataInicial
              ,'{finalDate}'::DATE	--pdDataFinal
              ,'EMISSAO'::VARCHAR    --pcFiltrarPorData
              ,COALESCE(0,0)::NUMERIC	--pnSaldoInicial
              ,'Não'::VARCHAR	--pcConsiderarSaldoBancos
              ,'Não'::VARCHAR	--pcConsiderarSaldoCaixa
              ,'Não'::VARCHAR	--pcFiltrarNaoFaturados
              ,'Não'::VARCHAR	--pcEntradasVencidas
              ,NULL::VARCHAR	-- pcCalcularPrevisao
              ,'Não'::VARCHAR	--pcFiltrarSaidas
              ,'Sim'::VARCHAR	--pcFiltrarCheques
              ,'Sim'::VARCHAR	--pcConsiderarOrdemCompra
              ,NULL::VARCHAR[] -- pcDocumentos
               ) AS retorno) AS retorno
GROUP BY
	retorno.datafluxo

UNION ALL
/* ******************************************
 * Saldo Contas de Aplicações
 ****************************************** */
SELECT
	'8. Saldo de Aplicações' AS tipofluxo
	,'1. Aplicações' AS grupofluxo
	,'1. Aplicações' AS subgrupofluxo
	,(contacorrente_saldo.banco || banco.nome || contacorrente_saldo.agencia || contacorrente_saldo.conta) AS descricaofluxo
	,datafluxo AS DATA
	,SUM(COALESCE(contacorrente_saldo.valorsaldo,banco_conta.valorsaldo)) AS valor
	,'Investimentos' AS origemdados
	,'' AS clientefornecedor
	,0 AS tipotitulo
FROM fnc_diasperiodo('{initialDate}' ,'{finalDate}') datafluxo

JOIN banco_conta
	ON  banco_conta.grupo = 1
	AND (COALESCE(1,0) = 0 OR banco_conta.empresa = COALESCE(1,0))
	AND banco_conta.considerarfluxocaixa = 1
	AND banco_conta.containvestimento = 1

JOIN banco
	ON  banco.codigo = banco_conta.banco

LEFT JOIN contacorrente_saldo
	ON  contacorrente_saldo.grupo = banco_conta.grupo
	AND contacorrente_saldo.empresa = banco_conta.empresa
	AND contacorrente_saldo.banco = banco_conta.banco
	AND contacorrente_saldo.agencia = banco_conta.agencia
	AND contacorrente_saldo.conta = banco_conta.conta
WHERE
	EXTRACT(DOW FROM datafluxo)NOT IN (0, 6)
	AND (contacorrente_saldo.dtmovimento = datafluxo
	     OR
	     contacorrente_saldo.dtmovimento = (SELECT
	                                        	MAX(dtmovimento)
	                                        FROM contacorrente_saldo

	                                        WHERE
	                                        	grupo = banco_conta.grupo
	                                        	AND empresa = banco_conta.empresa
	                                        	AND banco = banco_conta.banco
	                                        	AND agencia = banco_conta.agencia
	                                        	AND conta = banco_conta.conta
	                                        	AND dtmovimento <= datafluxo))
GROUP BY
	descricaofluxo
   ,datafluxo