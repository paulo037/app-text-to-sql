CREATE TABLE empresa (	
	cnpj_basico TEXT, -- Número base da inscrição no CNPJ
	nome TEXT, -- Nome empresarial da pessoa jurídica
	capital DOUBLE, -- Poder financeiro da empresa, valor investido pelos sócios quando o negócio ainda estava no início de suas atividades;
	ente_federativo_responsavel TEXT, -- commonsense evidence: preenchido para os casos de entidades do grupo de natureza jurídica 1XXX
	codigo_natureza_juridica INTEGER, -- Código da Natureza Jurídica;
	codigo_qualificacao_responsavel INTEGER, -- Código da qualificação da pessoa física responsável pela empresa
	codigo_porte_empresa INTEGER, -- Códio do porte/tamanho da empresa
	PRIMARY KEY (cnpj_basico),
	FOREIGN KEY(cnpj_basico) REFERENCES estabelecimento (cnpj_basico),
	FOREIGN KEY(codigo_natureza_juridica) REFERENCES natureza_juridica (codigo),
	FOREIGN KEY(codigo_qualificacao_responsavel) REFERENCES qualificacao (codigo),
	FOREIGN KEY(codigo_porte_empresa) REFERENCES porte_empresa (codigo)
)
	
CREATE TABLE estabelecimento (	
	cnpj_basico TEXT,  -- Número base da inscrição no CNPJ; commonsense evidence: 8 primeiros dígitos do CNPJ
	cnpj_ordem TEXT, -- Número do estabelecimento de insrição no CNPJ; commonsense evidence: 9 ao 12 dígito do CNPJ
	cnpj_digito_verificador TEXT, -- Dígito verificador de inscrição no CNPJ; commonsense evidence: dois últimos dígitos do CNPJ
	matriz_ou_filial TEXT, -- Identifica se o estabelecimento é 'Matriz' ou 'Filial'; commonsense evidence: 'Matriz': estabelecimento é a matriz; 'Filial':estabelecimento é uma filial
	nome TEXT, -- Nome fantasia;
	data_inicio_atividade DATE,
	codigo_cnae_principal INTEGER, -- Código da CNAE/atividade econômica/setor principal;
	codigo_cnae_secundaria TEXT,  -- Lista com os códigos das CNAE secundárias;
	codigo_cidade INTEGER, -- Código do município onde se encontra o estabelecimento;
	estado TEXT, -- Sigla do estado/unidade da federação em que se encontra o estabelecimento; commonsense evidence: a sigla do estado Goias, por exemplo, é GO
	codigo_pais INTEGER, -- commonsense evidence: caso o estabelecimento se encontra no exterior
	nome_cidade_estrangeira TEXT, -- commonsense evidence: caso o estabelecimento se encontra no exterior
	situacao_especial TEXT, -- commonsense evidence: caso a empresa esteja em alguma situação especial
	codigo_situacao_cadastral INTEGER,
	codigo_motivo_situacao_cadastral INTEGER,
	PRIMARY KEY (cnpj_basico, cnpj_ordem, cnpj_digito_verificador),
	FOREIGN KEY(codigo_cnae_principal) REFERENCES cnae (codigo),
	FOREIGN KEY(codigo_cidade) REFERENCES cidade (codigo),
	FOREIGN KEY(codigo_pais) REFERENCES pais (codigo),
	FOREIGN KEY(codigo_situacao_cadastral) REFERENCES situacao_cadastral (codigo),
	FOREIGN KEY(codigo_motivo_situacao_cadastral) REFERENCES motivo_situacao_cadastral (codigo)
)
	
CREATE TABLE socio (	
	cnpj_basico TEXT, -- Número base da inscrição no CNPJ
	nome TEXT,
	cpf_ou_cnpj TEXT, -- commonsense evidence: CPF se pessoa física, CNPJ se pessoa jurídica, se estrangeiro não tem valor;
	cpf_representante_legal TEXT,
	nome_representante_legal TEXT,
	codigo_tipo_socio INTEGER, -- Código do tipo do sócio
	codigo_qualificacao_socio INTEGER, -- Código da qualificação do sócio
	codigo_pais INTEGER, -- Código do País, se sócio estrangeiro
	codigo_qualificacao_representante_legal INTEGER, -- Código da qualificação do representante legal
	codigo_faixa_etaria INTEGER, -- Código da Faixa Etária
	FOREIGN KEY(cnpj_basico) REFERENCES estabelecimento (cnpj_basico),
	FOREIGN KEY(codigo_tipo_socio) REFERENCES tipo_socio (codigo),
	FOREIGN KEY(codigo_qualificacao_socio) REFERENCES qualificacao (codigo),
	FOREIGN KEY(codigo_qualificacao_representante_legal) REFERENCES qualificacao (codigo),
	FOREIGN KEY(codigo_pais) REFERENCES pais (codigo),
	FOREIGN KEY(codigo_faixa_etaria) REFERENCES faixa_etaria (codigo)
)
	
CREATE TABLE tributacao (	
	cnpj_basico TEXT, -- Número base da inscrição no CNPJ
	opcao_pelo_simples_nacional CHAR, -- Identifica se a forma de tributação é pelo simples nacional; commonsense evidence: 'S':optou, 'N': não optou
	opcao_pelo_mei CHAR, -- Identifica se a forma de tributação é pelo; commonsense evidence: 'S':optou, 'N': não optou
	data_opcao_simples_nacional DATE,
	data_exclusao_simples_nacional DATE,
	data_opcao_mei DATE,
	data_exclusao_mei DATE,
	FOREIGN KEY(cnpj_basico) REFERENCES estabelecimento (cnpj_basico)
)
	
CREATE TABLE faixa_etaria (	
	codigo INTEGER, -- Código único identificando a faixa etária
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE cidade (	
	codigo INTEGER, -- Código único identificando a cidade
	nome TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE cnae (	
	codigo INTEGER, -- Código único identificando a CNAE/atividade econômica/setor/ramo;
	nome TEXT, -- Nome da CNAE - Classificação Nacional de Atividade Econômica;
	PRIMARY KEY (codigo)
)
	
CREATE TABLE porte_empresa (	
	codigo INTEGER, -- Código único identificando o porte/tamanho da empresa;
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE pais (	
	codigo INTEGER, -- Código único identificando o país;
	nome TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE natureza_juridica (	
	codigo INTEGER, -- Código único identificando da natureza jurídica;
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE tipo_socio (	
	codigo INTEGER, -- Código único identificando um tipo de sócio;
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE qualificacao (	
	codigo INTEGER, -- Código único identificando uma qualificação;
	descricao TEXT,
	PRIMARY KEY (codigo)
)	

CREATE TABLE situacao_cadastral (	
	codigo INTEGER, -- Código único identificando uma situação cadastral;
	descricao TEXT,
	PRIMARY KEY (codigo)
)	

CREATE TABLE motivo_situacao_cadastral (	
	codigo INTEGER, -- Código único identificando o motivo da situação cadastral;
	descricao TEXT,
	PRIMARY KEY (codigo)
)	