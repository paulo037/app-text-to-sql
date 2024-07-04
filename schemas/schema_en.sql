CREATE TABLE company (	
	basic_cnpj TEXT,
	name TEXT,
	capital DOUBLE,
	responsible_federal_entity TEXT,
	legal_nature_code INTEGER,
	responsible_qualification_code INTEGER,
	company_size_code INTEGER,
	PRIMARY KEY (basic_cnpj),
	FOREIGN KEY(basic_cnpj) REFERENCES establishment (basic_cnpj),
	FOREIGN KEY(legal_nature_code) REFERENCES legal_nature (code),
	FOREIGN KEY(responsible_qualification_code) REFERENCES qualification (code),
	FOREIGN KEY(company_size_code) REFERENCES company_size (code)
)	

CREATE TABLE establishment (	
	basic_cnpj TEXT,
	order_cnpj TEXT,
	cnpj_verification_digit TEXT,
	main_or_branch TEXT,
	name TEXT,
	start_activity_date DATE,
	primary_cnae_code INTEGER,
	secondary_cnae_code TEXT,
	city_code INTEGER,
	state TEXT,
	country_code INTEGER,
	foreign_city_name TEXT,
	special_status TEXT,
	registration_status_code INTEGER,
	registration_status_reason_code INTEGER,
	PRIMARY KEY (basic_cnpj, order_cnpj, cnpj_verification_digit),
	FOREIGN KEY(primary_cnae_code) REFERENCES cnae (code),
	FOREIGN KEY(city_code) REFERENCES city (code),
	FOREIGN KEY(country_code) REFERENCES country (code),
	FOREIGN KEY(registration_status_code) REFERENCES registration_status (code),
	FOREIGN KEY(registration_status_reason_code) REFERENCES registration_status_reason (code)
)	

CREATE TABLE partner (	
	basic_cnpj TEXT,
	name TEXT,
	cpf_or_cnpj TEXT,
	legal_representative_cpf TEXT,
	legal_representative_name TEXT,
	partner_type_code INTEGER,
	partner_qualification_code INTEGER,
	country_code INTEGER,
	legal_representative_qualification_code INTEGER,
	age_range_code INTEGER,
	FOREIGN KEY(basic_cnpj) REFERENCES establishment (basic_cnpj),
	FOREIGN KEY(partner_type_code) REFERENCES partner_type (code),
	FOREIGN KEY(partner_qualification_code) REFERENCES qualification (code),
	FOREIGN KEY(legal_representative_qualification_code) REFERENCES qualification (code),
	FOREIGN KEY(country_code) REFERENCES country (code),
	FOREIGN KEY(age_range_code) REFERENCES age_range (code)
)	

CREATE TABLE taxation (	
	basic_cnpj TEXT,
	option_for_simples_taxation CHAR,
	option_for_mei_taxation CHAR,
	simples_taxation_option_date DATE,
	simples_taxation_exclusion_date DATE,
	mei_taxation_option_date DATE,
	mei_taxation_exclusion_date DATE,
	FOREIGN KEY(basic_cnpj) REFERENCES establishment (basic_cnpj)
)	

CREATE TABLE age_range (	
	code INTEGER,
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE city (	
	code INTEGER,
	name TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE cnae (	
	code INTEGER,
	name TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE company_size (	
	code INTEGER,
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE country (	
	code INTEGER,
	name TEXT, 
	PRIMARY KEY (code)
)	

CREATE TABLE legal_nature (	
	code INTEGER,
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE partner_type (	
	code INTEGER,
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE qualification (	
	code INTEGER,
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE registration_status (	
	code INTEGER,
	description TEXT,
	PRIMARY KEY (code)
)

CREATE TABLE registration_status_reason (	
	code INTEGER,
	description TEXT,
	PRIMARY KEY (code)
)	