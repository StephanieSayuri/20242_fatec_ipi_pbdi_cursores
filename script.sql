-- Active: 1726576516959@@localhost@1234@20242_ipi_pbdi_stephanie@public

-- Criar tabela:
CREATE TABLE tb_top_youtubers(
    cod_top_youtubers SERIAL PRIMARY KEY,
    rank INT,
    youtuber VARCHAR(200),
    subscribers INT,
    video_views INT,
    video_count INT,
    category VARCHAR(200),
    started INT
);

-- Encontre um campo apropriado para inteiros grandes
-- Escreva um ALTER TABLE trocando os inteiros para o tipo encontrado
ALTER TABLE tb_top_youtubers
    ALTER COLUMN video_views TYPE BIGINT;

SELECT * FROM tb_top_youtubers;
------------------------------------------------------------------------------------------------

-- Após editar a tabela e exportá-la no pgAdmin de modo que não possua mais erros, podemos começar o cursor:
DO
$$
DECLARE
    -- 1. Declaçaração do cursor
    -- Cursor não vinculado (unbound).
    -- Esse cursor exibe os nomes dos Youtubers um a um.ADD
    cur_nomes_youtubers REFCURSOR;
    v_youtuber VARCHAR(200);
BEGIN
    -- 2. Abertura do cursor.
    OPEN cur_nomes_youtubers FOR SELECT youtuber FROM tb_top_youtubers;
    LOOP
    -- 3. Recuperação dos dados de interesse.
        FETCH cur_nomes_youtubers INTO v_youtuber;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%', v_youtuber;
    END LOOP;
    -- 4. Fechamento do cursor.
    CLOSE cur_nomes_youtubers;
END;
$$;


-- Outro exemplo de um cursor não vinculado.
DO
$$
DECLARE
  -- Quando tem refcursor = não vinculado

  -- 1. declaraçã do cursor
  cur_nomes_a_partir_de refcursor;
  v_youtuber VARCHAR(200);
  v_ano INT := 2008;
  v_nome_tabela VARCHAR(200) := 'tb_top_youtubers';

BEGIN
  -- 2. abertura do cursor
    OPEN cur_nomes_a_partir_de FOR EXECUTE
    FORMAT('select youtuber from %s where started >= $1', v_nome_tabela) USING v_ano;
  
    LOOP
    -- 3. recuperação dos dados de interesse
        FETCH cur_nomes_a_partir_de INTO v_youtuber;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%', v_youtuber;
    END LOOP;

  -- 4. fechamento do cursor
    CLOSE cur_nomes_a_partir_de;
END;
$$;


-- Cursor vinculado (BOUND)
-- Concatenar nome e número de inscritos.
DO $$
DECLARE
    -- 1. Declaração do cursor:
    cur_nomes_e_inscritos CURSOR FOR SELECT youtuber, subscribers FROM tb_top_youtubers;
    v_tupla RECORD;
    v_resultado TEXT DEFAULT '';
BEGIN
    -- 2. Abertura do cursor:
    OPEN cur_nomes_e_inscritos;
    -- 3. Recuperação de dados:
    FETCH cur_nomes_e_inscritos INTO v_tupla;
    WHILE FOUND LOOP
        -- nome:1000
        v_resultado := v_resultado || v_tupla.youtuber || ':' || v_tupla.subscribers || ',';
        FETCH cur_nomes_e_inscritos INTO v_tupla;
    END LOOP;
    -- 4. Fechamento do cursor:
    CLOSE cur_nomes_e_inscritos;
    RAISE NOTICE '%', v_resultado;
END;
$$;


-- Cursor que usa parâmetros nomeados e pela ordem
-- Nomes dos youtubers que começaram a partir de 2010 e que têm pelo menos 60M de subscribers
DO $$
DECLARE
    -- 1. Declaração do cursor:
    v_ano INT := 2010;
    v_inscritos INT := 60000000; -- 60M
    v_youtuber VARCHAR(200);
    cur_ano_inscritos CURSOR(ano INT, inscritos INT) FOR SELECT youtuber FROM tb_top_youtubers
        WHERE STARTED >= ano AND subscribers >= inscritos;
BEGIN
    -- 2. Abertura do cursor:
    -- Há duas possibilidades:
    -- Argumentos por ordem:
    -- OPEN cur_ano_inscritos(v_ano, v_inscritos);
    -- Argumento nomeado:
    OPEN cur_ano_inscritos(inscritos := v_inscritos, ano := v_ano);
    LOOP
        -- 3. Recuperação de dados:
        FETCH cur_ano_inscritos INTO v_youtuber;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%', v_youtuber;
    END LOOP;
    -- 4. Fechamento do cursor:
    CLOSE cur_ano_inscritos;
END;
$$;


-- Cursor que faz UPDATE e DELETE e é capaz de subir:
DO $$
DECLARE
    -- 1. Declaração do cursor:
    cur_delete REFCURSOR;
    v_tupla RECORD;
BEGIN
    -- 2. Abertura do cursor:
    OPEN cur_delete SCROLL FOR SELECT * FROM tb_top_youtubers;
    LOOP
        -- 3. Recuperação de dados:
        FETCH cur_delete INTO v_tupla;
        EXIT WHEN NOT FOUND;
        IF v_tupla.video_count IS NULL THEN
            DELETE FROM tb_top_youtubers WHERE CURRENT OF cur_delete;
        END IF;
    END LOOP;
    -- Loop para exibir item a item, de baixo para cima;
    LOOP
        FETCH BACKWARD FROM cur_delete INTO v_tupla;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%', v_tupla;
    END LOOP;
    -- 4. Fechamento do cursor:
    CLOSE cur_delete;
END;
$$;

-- Exercícios da Apostila 16:
