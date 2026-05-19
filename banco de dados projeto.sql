-- ====================================================================
-- 1. TABELA: EMPRESA (Tabela Raiz)
-- ====================================================================
CREATE TABLE empresa (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    nome_empresa VARCHAR(150) NOT NULL,
    cnpj_empresa VARCHAR(18) NOT NULL UNIQUE, -- Adicionado campo essencial para empresas
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 2. TABELA: SETOR
-- ====================================================================
CREATE TABLE setor (
    id_setor INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    nome_setor VARCHAR(100) NOT NULL,
    descricao_setor VARCHAR(200),
    FOREIGN KEY (empresa_id)
        REFERENCES empresa (id_empresa)
        ON DELETE CASCADE
);

-- ====================================================================
-- 3. TABELA: USUARIO
-- ====================================================================
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    setor_id INT,
    nome_usuario VARCHAR(150) NOT NULL,
    email_usuario VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    cargo_usuario VARCHAR(100),
    perfil_usuario ENUM('admin', 'gestor', 'colaborador', 'cipa') DEFAULT 'colaborador',
    pontos_gamificacao INT DEFAULT 0,
    nivel_usuario INT DEFAULT 1,
    ativo_usuario BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (empresa_id)
        REFERENCES empresa (id_empresa)
        ON DELETE CASCADE,
    FOREIGN KEY (setor_id)
        REFERENCES setor (id_setor)
        ON DELETE SET NULL
);

-- ====================================================================
-- 4. TABELA: AREA MONITORADA
-- ====================================================================
CREATE TABLE area_monitorada (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    setor_id INT,
    nome_area VARCHAR(150) NOT NULL,
    tipo_area ENUM('pintura', 'forno', 'almoxarifado', 'producao', 'escritorio', 'outro') NOT NULL,
    descricao_area VARCHAR(300),
    FOREIGN KEY (empresa_id)
        REFERENCES empresa (id_empresa)
        ON DELETE CASCADE,
    FOREIGN KEY (setor_id)
        REFERENCES setor (id_setor)
        ON DELETE SET NULL
);

-- ====================================================================
-- 5. TABELA: DETECTOR
-- ====================================================================
CREATE TABLE detector (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area_id INT NOT NULL,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    tipo ENUM('fumaca', 'calor', 'chama', 'combinado') NOT NULL,
    fabricante VARCHAR(100),
    modelo VARCHAR(100),
    data_instalacao DATE,
    data_manutencao DATE,
    proxima_inspecao DATE,
    status ENUM('ativo', 'inativo', 'manutencao', 'falha') DEFAULT 'ativo',
    FOREIGN KEY (area_id)
        REFERENCES area_monitorada (id)
        ON DELETE CASCADE
);

-- ====================================================================
-- 6. TABELA: CENTRAL ALARME
-- ====================================================================
CREATE TABLE central_alarme (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    codigo_central VARCHAR(50) NOT NULL UNIQUE,
    localizacao_central VARCHAR(200),
    fabricante_central VARCHAR(100),
    modelo_central VARCHAR(100),
    data_instalacao DATE,
    status ENUM('ativo', 'inativo', 'manutencao') DEFAULT 'ativo',
    FOREIGN KEY (empresa_id)
        REFERENCES empresa (id_empresa)
        ON DELETE CASCADE
);

-- ====================================================================
-- 7. TABELA: EVENTO ALARME
-- ====================================================================
CREATE TABLE evento_alarme (
    id INT AUTO_INCREMENT PRIMARY KEY,
    central_id INT NOT NULL,
    detector_id INT,
    tipo_evento ENUM('fumaca', 'calor', 'falha', 'teste', 'acionamento_manual') NOT NULL,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duracao_seg INT,
    confirmado BOOLEAN DEFAULT FALSE,
    falso_alarme BOOLEAN DEFAULT FALSE,
    usuario_id INT,
    observacoes TEXT,
    FOREIGN KEY (central_id)
        REFERENCES central_alarme (id)
        ON DELETE CASCADE,
    FOREIGN KEY (detector_id)
        REFERENCES detector (id)
        ON DELETE SET NULL,
    FOREIGN KEY (usuario_id)
        REFERENCES usuario (id)
        ON DELETE SET NULL
);

-- ====================================================================
-- 8. TABELA: ILUMINACAO EMERGENCIA
-- ====================================================================
CREATE TABLE iluminacao_emergencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area_id INT NOT NULL,
    codigo_emergencia VARCHAR(50) NOT NULL UNIQUE,
    tipo_emergencia ENUM('bloco_autonomo', 'central', 'led_sinalizador') NOT NULL,
    localizacao_emergencia VARCHAR(200),
    data_instalacao DATE,
    autonomia_horas DECIMAL(4, 1),
    status ENUM('ok', 'falha', 'manutencao') DEFAULT 'ok',
    ultima_inspecao DATE,
    FOREIGN KEY (area_id)
        REFERENCES area_monitorada (id)
        ON DELETE CASCADE
);

-- ====================================================================
-- 9. TABELA: MEMBRO CIPA
-- ====================================================================
CREATE TABLE membro_cipa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    empresa_id INT NOT NULL,
    representacao ENUM('empregador', 'empregado') NOT NULL,
    cargo_cipa VARCHAR(100),
    mandato_inicio DATE,
    mandato_fim DATE,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (usuario_id)
        REFERENCES usuario (id)
        ON DELETE CASCADE,
    FOREIGN KEY (empresa_id)
        REFERENCES empresa (id_empresa)
        ON DELETE CASCADE
);

-- ====================================================================
-- 10. TABELA: REUNIAO CIPA
-- ====================================================================
CREATE TABLE reuniao_cipa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    data_hora DATETIME NOT NULL,
    tipo ENUM('ordinaria', 'extraordinaria') DEFAULT 'ordinaria',
    local VARCHAR(200),
    status ENUM('agendada', 'realizada', 'cancelada') DEFAULT 'agendada',
    pauta TEXT,
    FOREIGN KEY (empresa_id)
        REFERENCES empresa (id_empresa)
        ON DELETE CASCADE
);

-- ====================================================================
-- 11. TABELA: ATA CIPA
-- ====================================================================
CREATE TABLE ata_cipa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reuniao_id INT NOT NULL UNIQUE,
    conteudo_ata TEXT NOT NULL,
    arquivo_pdf VARCHAR(500),
    criado_por INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reuniao_id)
        REFERENCES reuniao_cipa (id)
        ON DELETE CASCADE,
    FOREIGN KEY (criado_por)
        REFERENCES usuario (id)
        ON DELETE SET NULL
);

-- ====================================================================
-- 12. TABELA: PRESENCA REUNIAO
-- ====================================================================
CREATE TABLE presenca_reuniao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reuniao_id INT NOT NULL,
    usuario_id INT NOT NULL,
    presente_reuniao BOOLEAN DEFAULT TRUE,
    UNIQUE KEY uq_presenca (reuniao_id, usuario_id),
    FOREIGN KEY (reuniao_id)
        REFERENCES reuniao_cipa (id)
        ON DELETE CASCADE,
    FOREIGN KEY (usuario_id)
        REFERENCES usuario (id)
        ON DELETE CASCADE
);

-- ====================================================================
-- 13. TABELA: INSPECAO
-- ====================================================================
CREATE TABLE inspecao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    setor_id INT,
    usuario_id INT NOT NULL,
    tipo_inspecao ENUM('rotina', 'especial', 'pos_ocorrencia', 'cipa') NOT NULL,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('aberta', 'concluida', 'pendente_acao') DEFAULT 'aberta',
    observacao_inspecao TEXT,
    pontos_obtidos INT DEFAULT 0,
    FOREIGN KEY (empresa_id)
        REFERENCES empresa (id_empresa)
        ON DELETE CASCADE,
    FOREIGN KEY (setor_id)
        REFERENCES setor (id_setor)
        ON DELETE SET NULL,
    FOREIGN KEY (usuario_id)
        REFERENCES usuario (id)
        ON DELETE CASCADE
);

-- ====================================================================
-- 14. TABELA: ITEM INSPECAO
-- ====================================================================
CREATE TABLE item_inspecao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inspecao_id INT NOT NULL,
    descricao VARCHAR(300) NOT NULL,
    conforme BOOLEAN,
    gravidade ENUM('baixa', 'media', 'alta', 'critica'),
    acao_corretiva TEXT,
    prazo DATE,
    responsavel_id INT,
    foto_url VARCHAR(500),
    FOREIGN KEY (inspecao_id)
        REFERENCES inspecao (id)
        ON DELETE CASCADE,
    FOREIGN KEY (responsavel_id)
        REFERENCES usuario (id)
        ON DELETE SET NULL
);

-- ====================================================================
-- 15. TABELA: QUASE ACIDENTE
-- ====================================================================
CREATE TABLE quase_acidente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    setor_id INT,
    usuario_id INT NOT NULL,
    descricao_acidente TEXT NOT NULL,
    local VARCHAR(200),
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    potential_dano ENUM('baixo', 'medio', 'alto', 'critico'),
    causa_raiz TEXT,
    acao_imediata TEXT,
    status ENUM('registrado', 'em_analise', 'encerrado') DEFAULT 'registrado',
    pontos_obtidos INT DEFAULT 15,
    FOREIGN KEY (empresa_id)
        REFERENCES empresa (id_empresa)
        ON DELETE CASCADE,
    FOREIGN KEY (setor_id)
        REFERENCES setor (id_setor)
        ON DELETE SET NULL,
    FOREIGN KEY (usuario_id)
        REFERENCES usuario (id)
        ON DELETE CASCADE
);

-- ====================================================================
-- 1. POPULANDO A TABELA: empresa
-- ====================================================================
INSERT INTO empresa (nome_empresa, cnpj_empresa) VALUES 
('TechSafe Manufatura S.A.', '12.345.678/0001-90'),
('LogiSeg Armazéns Gerais', '98.765.432/0001-10');

-- Nota: Para os próximos INSERTS, assumiremos que:
-- Empresa 1: TechSafe (id_empresa = 1)
-- Empresa 2: LogiSeg (id_empresa = 2)

-- ====================================================================
-- 2. POPULANDO A TABELA: setor
-- ====================================================================
INSERT INTO setor (empresa_id, nome_setor, descricao_setor) VALUES 
(1, 'Produção Industrial', 'Linha de montagem, fundição e usinagem'),
(1, 'Administração e RH', 'Escritórios centrais e diretoria'),
(2, 'Logística e Distribuição', 'Recebimento, conferência e estocagem em racks');

-- ====================================================================
-- 3. POPULANDO A TABELA: usuario
-- ====================================================================
INSERT INTO usuario (empresa_id, setor_id, nome_usuario, email_usuario, senha_hash, cargo_usuario, perfil_usuario, pontos_gamificacao, nivel_usuario, ativo_usuario) VALUES 
(1, 2, 'Carlos Henrique Silva', 'carlos.rh@techsafe.com', '$2y$10$e0myL5u..YIcyG6d.P1A9exX8J8bZ8bJb8Jb8Jb8Jb8Jb8Jb8Jb8J', 'Gerente de RH', 'admin', 100, 2, TRUE),
(1, 1, 'Ana Paula Souza', 'ana.cipa@techsafe.com', '$2y$10$e0myL5u..YIcyG6d.P1A9exX8J8bZ8bJb8Jb8Jb8Jb8Jb8Jb8Jb8J', 'Operadora de Máquinas', 'cipa', 450, 5, TRUE),
(1, 1, 'Marcos Oliveira', 'marcos.op@techsafe.com', '$2y$10$e0myL5u..YIcyG6d.P1A9exX8J8bZ8bJb8Jb8Jb8Jb8Jb8Jb8Jb8J', 'Soldador Industrial', 'colaborador', 50, 1, TRUE),
(2, 3, 'Beatriz Mendes', 'beatriz.mendes@logiseg.com', '$2y$10$e0myL5u..YIcyG6d.P1A9exX8J8bZ8bJb8Jb8Jb8Jb8Jb8Jb8Jb8J', 'Coordenadora de Logística', 'gestor', 220, 3, TRUE),
(1, 1, 'Roberto Jefferson', 'roberto.seg@techsafe.com', '$2y$10$e0myL5u..YIcyG6d.P1A9exX8J8bZ8bJb8Jb8Jb8Jb8Jb8Jb8Jb8J', 'Técnico de Seg. Trabalho', 'gestor', 310, 4, TRUE);

-- ====================================================================
-- 4. POPULANDO A TABELA: area_monitorada
-- ====================================================================
INSERT INTO area_monitorada (empresa_id, setor_id, nome_area, tipo_area, descricao_area) VALUES 
(1, 1, 'Galpão de Solda e Fornos', 'forno', 'Área industrial de alta temperatura'),
(1, 1, 'Cabine de Pintura Eletrostática', 'pintura', 'Zona com presença de vapores inflamáveis'),
(1, 2, 'Escritório Administrativo - Bloco A', 'escritorio', 'Área de cubículos e atendimento geral'),
(2, 3, 'Almoxarifado Central de Cargas', 'almoxarifado', 'Estoque verticalizado de alta rotatividade');

-- ====================================================================
-- 5. POPULANDO A TABELA: detector
-- ====================================================================
INSERT INTO detector (area_id, codigo, tipo, fabricante, modelo, data_instalacao, data_manutencao, proxima_inspecao, status) VALUES 
(1, 'DET-FORNO-01', 'calor', 'FireTech', 'FT-THERM-200', '2025-01-15', '2026-01-10', '2026-07-10', 'ativo'),
(1, 'DET-FORNO-02', 'chama', 'OpticFlame', 'OF-FLARE-X', '2025-01-15', '2026-03-02', '2026-09-02', 'ativo'),
(2, 'DET-PINT-01', 'combinado', 'SafeGas', 'SG-COMBO-90', '2025-03-20', '2026-02-18', '2026-08-18', 'ativo'),
(3, 'DET-ADM-01', 'fumaca', 'Intelibras', 'SMOKE-PLUS', '2024-06-10', '2025-12-01', '2026-06-01', 'manutencao'),
(4, 'DET-ALMOX-01', 'fumaca', 'FireTech', 'FT-SMOKE-100', '2025-08-12', '2026-02-10', '2026-08-10', 'ativo');

-- ====================================================================
-- 6. POPULANDO A TABELA: central_alarme
-- ====================================================================
INSERT INTO central_alarme (empresa_id, codigo_central, localizacao_central, fabricante_central, modelo_central, data_instalacao, status) VALUES 
(1, 'CTR-MÁSTER-01', 'Guarita Principal de Segurança - Portaria A', 'Siemens', 'Cerberus FIT', '2024-03-15', 'ativo'),
(1, 'CTR-INDUSTRIA-02', 'Sala Técnica do Bloco Operacional', 'Bosch', 'FPA-5000', '2025-05-11', 'ativo'),
(2, 'CTR-LOG-01', 'Sala de Monitoramento de Cargas', 'Intelibras', 'CIE 1250', '2025-01-20', 'ativo');

-- ====================================================================
-- 7. POPULANDO A TABELA: evento_alarme
-- ====================================================================
INSERT INTO evento_alarme (central_id, detector_id, tipo_evento, data_hora, duracao_seg, confirmado, falso_alarme, usuario_id, observacoes) VALUES 
(1, 1, 'calor', '2026-04-12 14:32:00', 45, TRUE, FALSE, 5, 'Pico térmico detectado próximo ao forno 2 durante processo de fundição.'),
(2, 5, 'fumaca', '2026-05-02 08:15:00', 12, TRUE, TRUE, 5, 'Falso alarme gerado por poeira excessiva durante a movimentação de cargas de cal.'),
(3, NULL, 'acionamento_manual', '2026-05-18 19:40:00', 120, TRUE, FALSE, 4, 'Botoeira acionada manualmente devido a princípio de fumaça em empilhadeira.');

-- ====================================================================
-- 8. POPULANDO A TABELA: iluminacao_emergencia
-- ====================================================================
INSERT INTO iluminacao_emergencia (area_id, codigo_emergencia, tipo_emergencia, localizacao_emergencia, data_instalacao, autonomia_horas, status, ultima_inspecao) VALUES 
(1, 'ILUM-FORNO-01', 'bloco_autonomo', 'Parede lateral esquerda - Próximo à saída de emergência 1', '2025-01-20', 3.5, 'ok', '2026-04-01'),
(1, 'ILUM-FORNO-02', 'led_sinalizador', 'Acima da porta de escape principal', '2025-01-20', 2.0, 'ok', '2026-04-01'),
(4, 'ILUM-ALMOX-01', 'central', 'Corredor Central de Racks - Coluna 12', '2025-06-15', 4.0, 'falha', '2026-05-10');

-- ====================================================================
-- 9. POPULANDO A TABELA: membro_cipa
-- ====================================================================
INSERT INTO membro_cipa (usuario_id, empresa_id, representacao, cargo_cipa, mandato_inicio, mandato_fim, ativo) VALUES 
(2, 1, 'empregado', 'Vice-Presidente da CIPA', '2026-01-01', '2026-12-31', TRUE),
(3, 1, 'empregado', 'Suplente Operacional', '2026-01-01', '2026-12-31', TRUE);

-- ====================================================================
-- 10. POPULANDO A TABELA: reuniao_cipa
-- ====================================================================
INSERT INTO reuniao_cipa (empresa_id, data_hora, tipo, local, status, pauta) VALUES 
(1, '2026-05-10 14:00:00', 'ordinaria', 'Sala de Reuniões do Bloco Administrativo', 'realizada', 'Análise estatística de quase acidentes do último mês e revisão dos blocos autônomos de iluminação.'),
(1, '2026-06-10 14:00:00', 'ordinaria', 'Sala de Reuniões do Bloco Administrativo', 'agendada', 'Planejamento da SIPAT 2026 e cronograma de inspeções de extintores.');

-- ====================================================================
-- 11. POPULANDO A TABELA: ata_cipa
-- ====================================================================
INSERT INTO ata_cipa (reuniao_id, conteudo_ata, arquivo_pdf, criado_por) VALUES 
(1, 'Aos dez dias do mês de maio de 2026, reuniu-se a comissão da CIPA... Foi debatido o problema da poeira gerando falsos alarmes nos detectores do almoxarifado. Ficou acordado que a manutenção fará uma limpeza quinzenal nos sensores.', 'arquivos/atas/ata_reuniao_2026_05_10.pdf', 2);

-- ====================================================================
-- 12. POPULANDO A TABELA: presenca_reuniao
-- ====================================================================
INSERT INTO presenca_reuniao (reuniao_id, usuario_id, presente_reuniao) VALUES 
(1, 2, TRUE),
(1, 3, TRUE),
(1, 5, TRUE);

-- ====================================================================
-- 13. POPULANDO A TABELA: inspecao
-- ====================================================================
INSERT INTO inspecao (empresa_id, setor_id, usuario_id, tipo_inspecao, data_hora, status, observacao_inspecao, pontos_obtidos) VALUES 
(1, 1, 5, 'cipa', '2026-05-12 09:00:00', 'concluida', 'Inspeção mensal de rotina focada em rotas de fuga e sistemas de combate a incêndio.', 80),
(1, 1, 2, 'rotina', '2026-05-19 10:30:00', 'aberta', 'Inspeção visual rápida nos postos de soldagem.', 0);

-- ====================================================================
-- 14. POPULANDO A TABELA: item_inspecao (Corrigido)
-- ====================================================================
INSERT INTO item_inspecao (inspecao_id, descricao, conforme, gravidade, acao_corretiva, prazo, responsavel_id, foto_url) VALUES 
(1, 'Verificação das placas de sinalização de saída de emergência.', TRUE, NULL, NULL, NULL, NULL, NULL),
(1, 'Teste de carga e funcionamento das luzes de emergência.', FALSE, 'media', 'Substituir a bateria do bloco de iluminação do corredor de racks.', '2026-05-25', 2, 'https://storage.techsafe.com/inspecoes/fotos/ilum_falha_01.jpg'),
(1, 'Avaliar obstrução de extintores de incêndio por paletes.', FALSE, 'alta', 'Remover paletes imediatamente e demarcar o solo corretamente.', '2026-05-20', 2, NULL);
-- 15. POPULANDO A TABELA: quase_acidente
-- ====================================================================
INSERT INTO quase_acidente (empresa_id, setor_id, usuario_id, descricao_acidente, local, data_hora, potential_dano, causa_raiz, acao_imediata, status, pontos_obtidos) VALUES 
(1, 1, 3, 'Palete de peças metálicas deslizou da empilhadeira durante curva na linha de montagem, caindo a menos de 1 metro de um operador.', 'Corredor principal da linha de montagem 2', '2026-05-15 11:20:00', 'alto', 'Carga mal estaiada/amarrada e velocidade incompatível do operador do equipamento.', 'Área isolada provisoriamente, carga recolhida e operador orientado no momento.', 'em_analise', 15);