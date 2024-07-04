CREATE TABLE empresa (	
	cnpj_basico TEXT,
	nome TEXT,
	capital DOUBLE,
	ente_federativo_responsavel TEXT,
	codigo_natureza_juridica INTEGER,
	codigo_qualificacao_responsavel INTEGER,
	codigo_porte_empresa INTEGER,
	PRIMARY KEY (cnpj_basico),
	FOREIGN KEY(cnpj_basico) REFERENCES estabelecimento (cnpj_basico),
	FOREIGN KEY(codigo_natureza_juridica) REFERENCES natureza_juridica (codigo),
	FOREIGN KEY(codigo_qualificacao_responsavel) REFERENCES qualificacao (codigo),
	FOREIGN KEY(codigo_porte_empresa) REFERENCES porte_empresa (codigo)
)
	
CREATE TABLE estabelecimento (	
	cnpj_basico TEXT,
	cnpj_ordem TEXT,
	cnpj_digito_verificador TEXT,
	matriz_ou_filial TEXT,
	nome TEXT,
	data_inicio_atividade DATE,
	codigo_cnae_principal INTEGER,
	codigo_cnae_secundaria TEXT,
	codigo_cidade INTEGER,
	estado TEXT,
	codigo_pais INTEGER,
	nome_cidade_estrangeira TEXT,
	situacao_especial TEXT,
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
	cnpj_basico TEXT,
	nome TEXT,
	cpf_ou_cnpj TEXT,
	cpf_representante_legal TEXT,
	nome_representante_legal TEXT,
	codigo_tipo_socio INTEGER,
	codigo_qualificacao_socio INTEGER,
	codigo_pais INTEGER,
	codigo_qualificacao_representante_legal INTEGER,
	codigo_faixa_etaria INTEGER,
	FOREIGN KEY(cnpj_basico) REFERENCES estabelecimento (cnpj_basico),
	FOREIGN KEY(codigo_tipo_socio) REFERENCES tipo_socio (codigo),
	FOREIGN KEY(codigo_qualificacao_socio) REFERENCES qualificacao (codigo),
	FOREIGN KEY(codigo_qualificacao_representante_legal) REFERENCES qualificacao (codigo),
	FOREIGN KEY(codigo_pais) REFERENCES pais (codigo),
	FOREIGN KEY(codigo_faixa_etaria) REFERENCES faixa_etaria (codigo)
)
	
CREATE TABLE tributacao (	
	cnpj_basico TEXT,
	opcao_pelo_simples_nacional CHAR,
	opcao_pelo_mei CHAR,
	data_opcao_simples_nacional DATE,
	data_exclusao_simples_nacional DATE,
	data_opcao_mei DATE,
	data_exclusao_mei DATE,
	FOREIGN KEY(cnpj_basico) REFERENCES estabelecimento (cnpj_basico)
)
	
CREATE TABLE faixa_etaria (	
	codigo INTEGER,
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE cidade (	
	codigo INTEGER,
	nome TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE cnae (	
	codigo INTEGER,
	nome TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE porte_empresa (	
	codigo INTEGER,
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE pais (	
	codigo INTEGER,
	nome TEXT, 
	PRIMARY KEY (codigo)
)
	
CREATE TABLE natureza_juridica (	
	codigo INTEGER,
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE tipo_socio (	
	codigo INTEGER,
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE qualificacao (	
	codigo INTEGER,
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE situacao_cadastral (	
	codigo INTEGER,
	descricao TEXT,
	PRIMARY KEY (codigo)
)
	
CREATE TABLE motivo_situacao_cadastral (	
	codigo INTEGER,
	descricao TEXT,
	PRIMARY KEY (codigo)
)	