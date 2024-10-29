-- Active: 1726576516959@@localhost@1234@20242_ipi_pbdi_stephanie@public

-- 1. Introdução
-- 1.1 Escreva um cursor que exiba as variáveis rank e youtuber de toda tupla que tiver
-- video_count pelo menos igual a 1000 e cuja category seja igual a Sports ou Music.
DO
$$
DECLARE
    cur_top_youtubers CURSOR FOR SELECT rank, youtuber FROM tb_top_youtubers
        WHERE video_count >= 1000 AND category IN ('Sports', 'Music');
    v_rank INT;
    v_youtuber VARCHAR(200);
BEGIN
    OPEN cur_top_youtubers;
    LOOP
        FETCH cur_top_youtubers INTO v_rank, v_youtuber;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Rank: %, Youtuber: %', v_rank, v_youtuber;
    END LOOP;
    CLOSE cur_top_youtubers;
END;
$$;

-- 1.2 Escreva um cursor que exibe todos os nomes dos youtubers em ordem reversa. Para tal
-- - O SELECT deverá ordenar em ordem não reversa
-- - O Cursor deverá ser movido para a última tupla
-- - Os dados deverão ser exibidos de baixo para cima
DO
$$
DECLARE
    -- Declaração do cursor com a ordem inversa no SELECT
    cur_nomes_youtubers REFCURSOR;
    v_youtuber VARCHAR(200);
BEGIN
    -- Abertura do cursor, ordenando em ordem decrescente
    OPEN cur_nomes_youtubers FOR SELECT youtuber FROM tb_top_youtubers ORDER BY youtuber DESC;
    LOOP
        -- Recuperação e exibição dos dados
        FETCH cur_nomes_youtubers INTO v_youtuber;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%', v_youtuber;
    END LOOP;
    -- Fechamento do cursor
    CLOSE cur_nomes_youtubers;
END;
$$;

-- 1.3 Faça uma pesquisa sobre o anti-pattern chamado RBAR - Row By Agonizing Row.
-- Explique com suas palavras do que se trata.

-- O anti-pattern RBAR (Row By Agonizing Row) é uma abordagem ineficiente para processar 
-- dados em bancos de dados, onde cada linha é manipulada individualmente em vez de trabalhar 
-- com várias linhas de uma vez. Isso resulta em um desempenho lento, uso excessivo de recursos e um 
-- código mais complexo e difícil de entender. Para melhorar a eficiência, é preferível utilizar 
-- comandos SQL que operem em conjuntos de dados, permitindo que as operações sejam realizadas 
-- mais rapidamente e com um código mais claro.