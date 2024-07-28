CREATE TABLE age_range (
	code INTEGER, 
	description TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from age_range table:
code	description
1	0 a 12 anos
2	13 a 20 anos
3	21 a 30 anos
*/


CREATE TABLE city (
	code INTEGER, 
	name TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from city table:
code	name
1	GUAJARA-MIRIM
2	ALTO ALEGRE DOS PARECIS
3	PORTO VELHO
*/


CREATE TABLE cnae (
	code INTEGER, 
	name TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from cnae table:
code	name
111301	Cultivo de arroz
111302	Cultivo de milho
111303	Cultivo de trigo
*/


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

/*
3 rows from company table:
basic_cnpj	name	capital	responsible_federal_entity	legal_nature_code	responsible_qualification_code	company_size_code
07834290	JAIRO ACOSTA DE OLIVEIRA	2000.0	None	2135	50	1
07838099	J. N. TAMANINI INDUSTRIA DO VESTUARIO LTDA	60000.0	None	2062	49	1
07851862	REGIA COMERCIO DE INFORMATICA LTDA EM RECUPERACAO JUDICIAL	1372000.0	None	2062	64	5
*/


CREATE TABLE company_size (
	code INTEGER, 
	description TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from company_size table:
code	description
0	NÃO INFORMADO
1	MICRO EMPRESA
3	EMPRESA DE PEQUENO PORTE
*/


CREATE TABLE country (
	code INTEGER, 
	name TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from country table:
code	name
0	COLIS POSTAUX
13	AFEGANISTAO
17	ALBANIA
*/


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

/*
3 rows from establishment table:
basic_cnpj	order_cnpj	cnpj_verification_digit	main_or_branch	name	start_activity_date	primary_cnae_code	secondary_cnae_code	city_code	state	country_code	foreign_city_name	special_status	registration_status_code	registration_status_reason_code
23311374	0001	23	Main	MARCENARIA DE VOLTA PRA MINHA TERRA	2015-09-21	3101200	None	2369	PE	None	None	None	8	1
20042201	0001	69	Main	NBS EMPREENDIMENTOS	2014-04-07	4110700	4313400,4391600,6822600,6810201,8111700,8129000,8130300,4120400,4330404,4211102,4330499,7820500,6204	7107	SP	None	None	None	2	0
23311395	0001	49	Main	None	2015-09-21	5611201	5611203	6477	SP	None	None	None	4	63
*/


CREATE TABLE legal_nature (
	code INTEGER, 
	description TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from legal_nature table:
code	description
0	Natureza Jurídica não informada
1015	Órgão Público do Poder Executivo Federal
1023	Órgão Público do Poder Executivo Estadual ou do Distrito Federal
*/


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

/*
3 rows from partner table:
basic_cnpj	name	cpf_or_cnpj	legal_representative_cpf	legal_representative_name	partner_type_code	partner_qualification_code	country_code	legal_representative_qualification_code	age_range_code
08318272	MARIANA SCHAPER BERNADELLI	**388076*	**000000*	None	2	49	None	0	5
08318272	LILIANE CARVALHO DOMINGOS	**996521*	**000000*	None	2	22	None	0	5
08478078	OSMAR CARRARO	**318948*	**000000*	None	2	59	None	0	6
*/


CREATE TABLE partner_type (
	code INTEGER, 
	description TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from partner_type table:
code	description
1	PESSOA JURÍDICA
2	PESSOA FÍSICA
3	ESTRANGEIRO
*/


CREATE TABLE qualification (
	code INTEGER, 
	description TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from qualification table:
code	description
0	Não informada
5	Administrador
8	Conselheiro de Administração
*/


CREATE TABLE registration_status (
	code INTEGER, 
	description TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from registration_status table:
code	description
1	NULA
2	ATIVA
3	SUSPENSA
*/


CREATE TABLE registration_status_reason (
	code INTEGER, 
	description TEXT, 
	PRIMARY KEY (code)
)

/*
3 rows from registration_status_reason table:
code	description
0	SEM MOTIVO
1	EXTINCAO POR ENCERRAMENTO LIQUIDACAO VOLUNTARIA
2	INCORPORACAO
*/


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

/*
3 rows from taxation table:
basic_cnpj	option_for_simples_taxation	option_for_mei_taxation	simples_taxation_option_date	simples_taxation_exclusion_date	mei_taxation_option_date	mei_taxation_exclusion_date
41826769	S	N	2007-07-01	None	None	None
40950354	N	N	2007-07-01	2017-11-30	None	None
41031766	N	N	2012-01-01	2012-12-31	None	None
*/