CREATE TABLE company (	
	basic_cnpj TEXT, -- CNPJ registration base number;
	name TEXT,  -- business name of the legal entity;
	capital DOUBLE, -- the financial power of a company, the amount invested by the partners when the business was still in the beginning of its activities;
	responsible_federal_entity TEXT, -- commonsense evidence: filled in for cases of entities in the legal group 1XXX
	legal_nature_code INTEGER, -- Code of Legal Nature;
	responsible_qualification_code INTEGER, -- Qualification code of the responsible for the company
	company_size_code INTEGER, -- Code of Company Size
	PRIMARY KEY (basic_cnpj),
	FOREIGN KEY(basic_cnpj) REFERENCES establishment (basic_cnpj),
	FOREIGN KEY(legal_nature_code) REFERENCES legal_nature (code),
	FOREIGN KEY(responsible_qualification_code) REFERENCES qualification (code),
	FOREIGN KEY(company_size_code) REFERENCES company_size (code)
)
	
CREATE TABLE establishment (	
	basic_cnpj TEXT, -- CNPJ registration base number;
	order_cnpj TEXT, -- CNPJ registration establishment number; commonsense evidence: 9 to 12 digits of CNPJ
	cnpj_verification_digit TEXT, -- CNPJ registration check digit; commonsense evidence: last two digits of the CNPJ
	main_or_branch TEXT,-- Identifies whether the establishment is 'Main' or 'Branch'; commonsense evidence: 'Main': establishment is the main; 'Branch': establishment is a branch
	name TEXT, -- Fantasy name;
	start_activity_date DATE,
	primary_cnae_code INTEGER, -- Code of the Primary CNAE/economic activity/sector;
	secondary_cnae_code TEXT, -- List of secondary CNAE codes;
	city_code INTEGER, -- Code of the city where the establishment is located;
	state TEXT, -- Acronym of the state in which the establishment is located; commonsense evidence: the acronym for the state of Goias, for example, is GO
	country_code INTEGER,-- commonsense evidence: if the establishment is located abroad
	foreign_city_name TEXT, -- commonsense evidence: if the establishment is located abroad
	special_status TEXT,-- commonsense evidence: if the company is in any special situation
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
	basic_cnpj TEXT, -- CNPJ registration base number;
	name TEXT,
	cpf_or_cnpj TEXT,
	legal_representative_cpf TEXT,
	legal_representative_name TEXT,
	partner_type_code INTEGER, -- Code of the partner type 
	partner_qualification_code INTEGER, -- Code of the qualification of the partner 
	country_code INTEGER, -- Code of the country 
	legal_representative_qualification_code INTEGER, -- Code of the qualification of the legal representative
	age_range_code INTEGER, -- Code of the partner age range
	FOREIGN KEY(basic_cnpj) REFERENCES establishment (basic_cnpj),
	FOREIGN KEY(partner_type_code) REFERENCES partner_type (code),
	FOREIGN KEY(partner_qualification_code) REFERENCES qualification (code),
	FOREIGN KEY(legal_representative_qualification_code) REFERENCES qualification (code),
	FOREIGN KEY(country_code) REFERENCES country (code),
	FOREIGN KEY(age_range_code) REFERENCES age_range (code)
)	

CREATE TABLE taxation (	
	basic_cnpj TEXT, -- CNPJ registration base number;
	option_for_simples_taxation CHAR, -- Identifies whether the form of taxation is simples; commonsense evidence: 'S': opted, 'N': did not opt
	option_for_mei_taxation CHAR, -- Identifies whether the form of taxation is mei; commonsense evidence: 'S': opted, 'N': did not opt
	simples_taxation_option_date DATE,
	simples_taxation_exclusion_date DATE,
	mei_taxation_option_date DATE,
	mei_taxation_exclusion_date DATE,
	FOREIGN KEY(basic_cnpj) REFERENCES establishment (basic_cnpj)
)	

CREATE TABLE age_range (	
	code INTEGER, -- Unique number indendifying age range;
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE city (	
	code INTEGER, -- Unique number indendifying city;
	name TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE cnae (	
	code INTEGER, -- Unique number indendifying cnae, economicy activity, setor;
	name TEXT, -- Name of the cnae - classification of economic activities - economic setor;
	PRIMARY KEY (code)
)	

CREATE TABLE company_size (	
	code INTEGER, -- Unique number indendifying company size;
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE country (	
	code INTEGER, -- Unique number indendifying country;
	nome TEXT, 
	PRIMARY KEY (code)
)

CREATE TABLE legal_nature (	
	code INTEGER, -- Unique number indendifying legal_nature;
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE partner_type (	
	code INTEGER, -- Unique number indendifying partner type;
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE qualification (	
	code INTEGER, -- Unique number indendifying qualification;
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE registration_status (	
	code INTEGER, -- Unique number indendifying registration status;
	description TEXT,
	PRIMARY KEY (code)
)	

CREATE TABLE registration_status_reason (	
	code INTEGER, -- Unique number indendifying registration status reason;
	description TEXT,
	PRIMARY KEY (code)
)	