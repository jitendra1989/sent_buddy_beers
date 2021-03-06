class AddDialingPrefixToCountries < ActiveRecord::Migration
  def self.up
    add_column :countries, :dialing_prefix, :integer
    
    Country.find_by_printable_name('Afghanistan').update_attribute(:dialing_prefix, 93)
    Country.find_by_printable_name('Albania').update_attribute(:dialing_prefix, 355)
    Country.find_by_printable_name('Algeria').update_attribute(:dialing_prefix, 213)
    Country.find_by_printable_name('American Samoa').update_attribute(:dialing_prefix, 1684)
    Country.find_by_printable_name('Andorra').update_attribute(:dialing_prefix, 376) 
    Country.find_by_printable_name('Angola').update_attribute(:dialing_prefix, 244) 
    Country.find_by_printable_name('Anguilla').update_attribute(:dialing_prefix, 1264) 
    Country.find_by_printable_name('Antigua and Barbuda').update_attribute(:dialing_prefix, 1268) 
    Country.find_by_printable_name('Argentina').update_attribute(:dialing_prefix, 54) 
    Country.find_by_printable_name('Armenia').update_attribute(:dialing_prefix, 374) 
    Country.find_by_printable_name('Aruba').update_attribute(:dialing_prefix, 297) 
    Country.find_by_printable_name('Australia').update_attribute(:dialing_prefix, 61) 
    Country.find_by_printable_name('Austria').update_attribute(:dialing_prefix, 43) 
    Country.find_by_printable_name('Azerbaijan').update_attribute(:dialing_prefix, 994) 
    Country.find_by_printable_name('Bahamas').update_attribute(:dialing_prefix, 1242) 
    Country.find_by_printable_name('Bahrain').update_attribute(:dialing_prefix, 973) 
    Country.find_by_printable_name('Bangladesh').update_attribute(:dialing_prefix, 880) 
    Country.find_by_printable_name('Barbados').update_attribute(:dialing_prefix, 1246) 
    Country.find_by_printable_name('Belarus').update_attribute(:dialing_prefix, 375) 
    Country.find_by_printable_name('Belgium').update_attribute(:dialing_prefix, 32) 
    Country.find_by_printable_name('Belize').update_attribute(:dialing_prefix, 501) 
    Country.find_by_printable_name('Benin').update_attribute(:dialing_prefix, 229) 
    Country.find_by_printable_name('Bermuda').update_attribute(:dialing_prefix, 1441) 
    Country.find_by_printable_name('Bhutan').update_attribute(:dialing_prefix, 975) 
    Country.find_by_printable_name('Bolivia').update_attribute(:dialing_prefix, 591) 
    Country.find_by_printable_name('Bosnia and Herzegovina').update_attribute(:dialing_prefix, 387) 
    Country.find_by_printable_name('Botswana').update_attribute(:dialing_prefix, 267) 
    Country.find_by_printable_name('Brazil').update_attribute(:dialing_prefix, 55) 
    Country.find_by_printable_name('Brunei Darussalam').update_attribute(:dialing_prefix, 673) 
    Country.find_by_printable_name('Bulgaria').update_attribute(:dialing_prefix, 359) 
    Country.find_by_printable_name('Burkina Faso').update_attribute(:dialing_prefix, 226) 
    Country.find_by_printable_name('Burundi').update_attribute(:dialing_prefix, 257) 
    Country.find_by_printable_name('Cambodia').update_attribute(:dialing_prefix, 855) 
    Country.find_by_printable_name('Cameroon').update_attribute(:dialing_prefix, 237) 
    Country.find_by_printable_name('Canada').update_attribute(:dialing_prefix, 1) 
    Country.find_by_printable_name('Cape Verde').update_attribute(:dialing_prefix, 238) 
    Country.find_by_printable_name('Cayman Islands').update_attribute(:dialing_prefix, 1345) 
    Country.find_by_printable_name('Central African Republic').update_attribute(:dialing_prefix, 236) 
    Country.find_by_printable_name('Chad').update_attribute(:dialing_prefix, 235) 
    Country.find_by_printable_name('Chile').update_attribute(:dialing_prefix, 56) 
    Country.find_by_printable_name('China').update_attribute(:dialing_prefix, 86) 
    Country.find_by_printable_name('Colombia').update_attribute(:dialing_prefix, 57) 
    Country.find_by_printable_name('Comoros').update_attribute(:dialing_prefix, 269) 
    Country.find_by_printable_name('Congo').update_attribute(:dialing_prefix, 242) 
    Country.find_by_printable_name('Congo, the Democratic Republic of the').update_attribute(:dialing_prefix, 243) 
    Country.find_by_printable_name('Cook Islands').update_attribute(:dialing_prefix, 682) 
    Country.find_by_printable_name('Costa Rica').update_attribute(:dialing_prefix, 506) 
    Country.find_by_printable_name('Cote D\'Ivoire').update_attribute(:dialing_prefix, 225) 
    Country.find_by_printable_name('Croatia').update_attribute(:dialing_prefix, 385) 
    Country.find_by_printable_name('Cuba').update_attribute(:dialing_prefix, 53) 
    Country.find_by_printable_name('Cyprus').update_attribute(:dialing_prefix, 357) 
    Country.find_by_printable_name('Czech Republic').update_attribute(:dialing_prefix, 420) 
    Country.find_by_printable_name('Denmark').update_attribute(:dialing_prefix, 45) 
    Country.find_by_printable_name('Djibouti').update_attribute(:dialing_prefix, 253) 
    Country.find_by_printable_name('Dominica').update_attribute(:dialing_prefix, 1767) 
    Country.find_by_printable_name('Dominican Republic').update_attribute(:dialing_prefix, 1) 
    Country.find_by_printable_name('Ecuador').update_attribute(:dialing_prefix, 593) 
    Country.find_by_printable_name('Egypt').update_attribute(:dialing_prefix, 20) 
    Country.find_by_printable_name('El Salvador').update_attribute(:dialing_prefix, 503) 
    Country.find_by_printable_name('Equatorial Guinea').update_attribute(:dialing_prefix, 240) 
    Country.find_by_printable_name('Eritrea').update_attribute(:dialing_prefix, 291) 
    Country.find_by_printable_name('Estonia').update_attribute(:dialing_prefix, 372) 
    Country.find_by_printable_name('Ethiopia').update_attribute(:dialing_prefix, 251) 
    Country.find_by_printable_name('Falkland Islands (Malvinas)').update_attribute(:dialing_prefix, 500) 
    Country.find_by_printable_name('Faroe Islands').update_attribute(:dialing_prefix, 298) 
    Country.find_by_printable_name('Fiji').update_attribute(:dialing_prefix, 679) 
    Country.find_by_printable_name('Finland').update_attribute(:dialing_prefix, 358) 
    Country.find_by_printable_name('France').update_attribute(:dialing_prefix, 33) 
    Country.find_by_printable_name('French Guiana').update_attribute(:dialing_prefix, 594) 
    Country.find_by_printable_name('French Polynesia').update_attribute(:dialing_prefix, 689) 
    Country.find_by_printable_name('Gabon').update_attribute(:dialing_prefix, 241) 
    Country.find_by_printable_name('Gambia').update_attribute(:dialing_prefix, 220) 
    Country.find_by_printable_name('Georgia').update_attribute(:dialing_prefix, 995) 
    Country.find_by_printable_name('Germany').update_attribute(:dialing_prefix, 49) 
    Country.find_by_printable_name('Ghana').update_attribute(:dialing_prefix, 233) 
    Country.find_by_printable_name('Gibraltar').update_attribute(:dialing_prefix, 350) 
    Country.find_by_printable_name('Greece').update_attribute(:dialing_prefix, 30) 
    Country.find_by_printable_name('Greenland').update_attribute(:dialing_prefix, 299) 
    Country.find_by_printable_name('Grenada').update_attribute(:dialing_prefix, 1473) 
    Country.find_by_printable_name('Guadeloupe').update_attribute(:dialing_prefix, 590) 
    Country.find_by_printable_name('Guam').update_attribute(:dialing_prefix, 1671) 
    Country.find_by_printable_name('Guatemala').update_attribute(:dialing_prefix, 502) 
    Country.find_by_printable_name('Guinea').update_attribute(:dialing_prefix, 224) 
    Country.find_by_printable_name('Guinea-Bissau').update_attribute(:dialing_prefix, 245) 
    Country.find_by_printable_name('Guyana').update_attribute(:dialing_prefix, 592) 
    Country.find_by_printable_name('Haiti').update_attribute(:dialing_prefix, 509) 
    Country.find_by_printable_name('Holy See (Vatican City State)').update_attribute(:dialing_prefix, +39) 
    Country.find_by_printable_name('Honduras').update_attribute(:dialing_prefix, 504) 
    Country.find_by_printable_name('Hong Kong').update_attribute(:dialing_prefix, 852) 
    Country.find_by_printable_name('Hungary').update_attribute(:dialing_prefix, 36) 
    Country.find_by_printable_name('Iceland').update_attribute(:dialing_prefix, 354) 
    Country.find_by_printable_name('India').update_attribute(:dialing_prefix, 91) 
    Country.find_by_printable_name('Indonesia').update_attribute(:dialing_prefix, 62) 
    Country.find_by_printable_name('Iran, Islamic Republic of').update_attribute(:dialing_prefix, 98) 
    Country.find_by_printable_name('Iraq').update_attribute(:dialing_prefix, 964) 
    Country.find_by_printable_name('Ireland').update_attribute(:dialing_prefix, 353) 
    Country.find_by_printable_name('Israel').update_attribute(:dialing_prefix, 972) 
    Country.find_by_printable_name('Italy').update_attribute(:dialing_prefix, 39) 
    Country.find_by_printable_name('Jamaica').update_attribute(:dialing_prefix, 1876) 
    Country.find_by_printable_name('Japan').update_attribute(:dialing_prefix, 81) 
    Country.find_by_printable_name('Jordan').update_attribute(:dialing_prefix, 962) 
    Country.find_by_printable_name('Kazakhstan').update_attribute(:dialing_prefix, 7) 
    Country.find_by_printable_name('Kenya').update_attribute(:dialing_prefix, 254) 
    Country.find_by_printable_name('Kiribati').update_attribute(:dialing_prefix, 686) 
    Country.find_by_printable_name('Korea, Democratic People\'s Republic of').update_attribute(:dialing_prefix, 850) 
    Country.find_by_printable_name('Korea, Republic of').update_attribute(:dialing_prefix, 82) 
    Country.find_by_printable_name('Kuwait').update_attribute(:dialing_prefix, 965) 
    Country.find_by_printable_name('Kyrgyzstan').update_attribute(:dialing_prefix, 996) 
    Country.find_by_printable_name('Lao People\'s Democratic Republic').update_attribute(:dialing_prefix, 856) 
    Country.find_by_printable_name('Latvia').update_attribute(:dialing_prefix, 371) 
    Country.find_by_printable_name('Lebanon').update_attribute(:dialing_prefix, 961) 
    Country.find_by_printable_name('Lesotho').update_attribute(:dialing_prefix, 266) 
    Country.find_by_printable_name('Liberia').update_attribute(:dialing_prefix, 231) 
    Country.find_by_printable_name('Libyan Arab Jamahiriya').update_attribute(:dialing_prefix, 218) 
    Country.find_by_printable_name('Liechtenstein').update_attribute(:dialing_prefix, 423) 
    Country.find_by_printable_name('Lithuania').update_attribute(:dialing_prefix, 370) 
    Country.find_by_printable_name('Luxembourg').update_attribute(:dialing_prefix, 352) 
    Country.find_by_printable_name('Macao').update_attribute(:dialing_prefix, 853) 
    Country.find_by_printable_name('Macedonia, the Former Yugoslav Republic of').update_attribute(:dialing_prefix, 389) 
    Country.find_by_printable_name('Madagascar').update_attribute(:dialing_prefix, 261) 
    Country.find_by_printable_name('Malawi').update_attribute(:dialing_prefix, 265) 
    Country.find_by_printable_name('Malaysia').update_attribute(:dialing_prefix, 60) 
    Country.find_by_printable_name('Maldives').update_attribute(:dialing_prefix, 960) 
    Country.find_by_printable_name('Mali').update_attribute(:dialing_prefix, 223) 
    Country.find_by_printable_name('Malta').update_attribute(:dialing_prefix, 356) 
    Country.find_by_printable_name('Marshall Islands').update_attribute(:dialing_prefix, 692) 
    Country.find_by_printable_name('Martinique').update_attribute(:dialing_prefix, 596) 
    Country.find_by_printable_name('Mauritania').update_attribute(:dialing_prefix, 222) 
    Country.find_by_printable_name('Mauritius').update_attribute(:dialing_prefix, 230) 
    Country.find_by_printable_name('Mexico').update_attribute(:dialing_prefix, 52) 
    Country.find_by_printable_name('Micronesia, Federated States of').update_attribute(:dialing_prefix, 691) 
    Country.find_by_printable_name('Moldova, Republic of').update_attribute(:dialing_prefix, 373) 
    Country.find_by_printable_name('Monaco').update_attribute(:dialing_prefix, 377) 
    Country.find_by_printable_name('Mongolia').update_attribute(:dialing_prefix, 976) 
    Country.find_by_printable_name('Montserrat').update_attribute(:dialing_prefix, 1664) 
    Country.find_by_printable_name('Morocco').update_attribute(:dialing_prefix, 212) 
    Country.find_by_printable_name('Mozambique').update_attribute(:dialing_prefix, 258) 
    Country.find_by_printable_name('Myanmar').update_attribute(:dialing_prefix, 95) 
    Country.find_by_printable_name('Namibia').update_attribute(:dialing_prefix, 264) 
    Country.find_by_printable_name('Nauru').update_attribute(:dialing_prefix, 674) 
    Country.find_by_printable_name('Nepal').update_attribute(:dialing_prefix, 977) 
    Country.find_by_printable_name('Netherlands').update_attribute(:dialing_prefix, 31) 
    Country.find_by_printable_name('Netherlands Antilles').update_attribute(:dialing_prefix, 599) 
    Country.find_by_printable_name('New Caledonia').update_attribute(:dialing_prefix, 687) 
    Country.find_by_printable_name('New Zealand').update_attribute(:dialing_prefix, 64) 
    Country.find_by_printable_name('Nicaragua').update_attribute(:dialing_prefix, 505) 
    Country.find_by_printable_name('Niger').update_attribute(:dialing_prefix, 227) 
    Country.find_by_printable_name('Nigeria').update_attribute(:dialing_prefix, 234) 
    Country.find_by_printable_name('Niue').update_attribute(:dialing_prefix, 683) 
    Country.find_by_printable_name('Norfolk Island').update_attribute(:dialing_prefix, 672) 
    Country.find_by_printable_name('Northern Mariana Islands').update_attribute(:dialing_prefix, 1670) 
    Country.find_by_printable_name('Norway').update_attribute(:dialing_prefix, 47) 
    Country.find_by_printable_name('Oman').update_attribute(:dialing_prefix, 968) 
    Country.find_by_printable_name('Pakistan').update_attribute(:dialing_prefix, 92) 
    Country.find_by_printable_name('Palau').update_attribute(:dialing_prefix, 680) 
    Country.find_by_printable_name('Panama').update_attribute(:dialing_prefix, 507) 
    Country.find_by_printable_name('Papua New Guinea').update_attribute(:dialing_prefix, 675) 
    Country.find_by_printable_name('Paraguay').update_attribute(:dialing_prefix, 595) 
    Country.find_by_printable_name('Peru').update_attribute(:dialing_prefix, 51) 
    Country.find_by_printable_name('Philippines').update_attribute(:dialing_prefix, 63) 
    Country.find_by_printable_name('Pitcairn').update_attribute(:dialing_prefix, 64) 
    Country.find_by_printable_name('Poland').update_attribute(:dialing_prefix, 48) 
    Country.find_by_printable_name('Portugal').update_attribute(:dialing_prefix, 351) 
    Country.find_by_printable_name('Puerto Rico').update_attribute(:dialing_prefix, 1787) 
    Country.find_by_printable_name('Qatar').update_attribute(:dialing_prefix, 974) 
    Country.find_by_printable_name('Reunion').update_attribute(:dialing_prefix, 262) 
    Country.find_by_printable_name('Romania').update_attribute(:dialing_prefix, 40) 
    Country.find_by_printable_name('Russian Federation').update_attribute(:dialing_prefix, 7) 
    Country.find_by_printable_name('Rwanda').update_attribute(:dialing_prefix, 250) 
    Country.find_by_printable_name('Saint Helena').update_attribute(:dialing_prefix, 290) 
    Country.find_by_printable_name('Saint Kitts and Nevis').update_attribute(:dialing_prefix, 1869) 
    Country.find_by_printable_name('Saint Lucia').update_attribute(:dialing_prefix, 1758) 
    Country.find_by_printable_name('Saint Pierre and Miquelon').update_attribute(:dialing_prefix, 508) 
    Country.find_by_printable_name('Saint Vincent and the Grenadines').update_attribute(:dialing_prefix, 1784) 
    Country.find_by_printable_name('Samoa').update_attribute(:dialing_prefix, 685) 
    Country.find_by_printable_name('San Marino').update_attribute(:dialing_prefix, 378) 
    Country.find_by_printable_name('Sao Tome and Principe').update_attribute(:dialing_prefix, 239) 
    Country.find_by_printable_name('Saudi Arabia').update_attribute(:dialing_prefix, 966) 
    Country.find_by_printable_name('Senegal').update_attribute(:dialing_prefix, 221) 
    Country.find_by_printable_name('Seychelles').update_attribute(:dialing_prefix, 248) 
    Country.find_by_printable_name('Sierra Leone').update_attribute(:dialing_prefix, 232) 
    Country.find_by_printable_name('Singapore').update_attribute(:dialing_prefix, 65) 
    Country.find_by_printable_name('Slovakia').update_attribute(:dialing_prefix, 421) 
    Country.find_by_printable_name('Slovenia').update_attribute(:dialing_prefix, 386) 
    Country.find_by_printable_name('Solomon Islands').update_attribute(:dialing_prefix, 677) 
    Country.find_by_printable_name('Somalia').update_attribute(:dialing_prefix, 252) 
    Country.find_by_printable_name('South Africa').update_attribute(:dialing_prefix, 27) 
    Country.find_by_printable_name('Spain').update_attribute(:dialing_prefix, 34) 
    Country.find_by_printable_name('Sri Lanka').update_attribute(:dialing_prefix, 94) 
    Country.find_by_printable_name('Sudan').update_attribute(:dialing_prefix, 249) 
    Country.find_by_printable_name('Suriname').update_attribute(:dialing_prefix, 597) 
    Country.find_by_printable_name('Svalbard and Jan Mayen').update_attribute(:dialing_prefix, 47) 
    Country.find_by_printable_name('Swaziland').update_attribute(:dialing_prefix, 268) 
    Country.find_by_printable_name('Sweden').update_attribute(:dialing_prefix, 46) 
    Country.find_by_printable_name('Switzerland').update_attribute(:dialing_prefix, 41) 
    Country.find_by_printable_name('Syrian Arab Republic').update_attribute(:dialing_prefix, 963) 
    Country.find_by_printable_name('Taiwan, Province of China').update_attribute(:dialing_prefix, 886) 
    Country.find_by_printable_name('Tajikistan').update_attribute(:dialing_prefix, 992) 
    Country.find_by_printable_name('Tanzania, United Republic of').update_attribute(:dialing_prefix, 255) 
    Country.find_by_printable_name('Thailand').update_attribute(:dialing_prefix, 66) 
    Country.find_by_printable_name('Togo').update_attribute(:dialing_prefix, 228) 
    Country.find_by_printable_name('Tokelau').update_attribute(:dialing_prefix, 790) 
    Country.find_by_printable_name('Tonga').update_attribute(:dialing_prefix, 676) 
    Country.find_by_printable_name('Trinidad and Tobago').update_attribute(:dialing_prefix, 1868) 
    Country.find_by_printable_name('Tunisia').update_attribute(:dialing_prefix, 216) 
    Country.find_by_printable_name('Turkey').update_attribute(:dialing_prefix, 90) 
    Country.find_by_printable_name('Turkmenistan').update_attribute(:dialing_prefix, 993) 
    Country.find_by_printable_name('Turks and Caicos Islands').update_attribute(:dialing_prefix, 1649) 
    Country.find_by_printable_name('Tuvalu').update_attribute(:dialing_prefix, 688) 
    Country.find_by_printable_name('Uganda').update_attribute(:dialing_prefix, 256) 
    Country.find_by_printable_name('Ukraine').update_attribute(:dialing_prefix, 380) 
    Country.find_by_printable_name('United Arab Emirates').update_attribute(:dialing_prefix, 971) 
    Country.find_by_printable_name('United Kingdom').update_attribute(:dialing_prefix, 44) 
    Country.find_by_printable_name('United States').update_attribute(:dialing_prefix, 1) 
    Country.find_by_printable_name('Uruguay').update_attribute(:dialing_prefix, 598) 
    Country.find_by_printable_name('Uzbekistan').update_attribute(:dialing_prefix, 998) 
    Country.find_by_printable_name('Vanuatu').update_attribute(:dialing_prefix, 678) 
    Country.find_by_printable_name('Venezuela').update_attribute(:dialing_prefix, 58) 
    Country.find_by_printable_name('Viet Nam').update_attribute(:dialing_prefix, 84) 
    Country.find_by_printable_name('Virgin Islands, British').update_attribute(:dialing_prefix, 1284) 
    Country.find_by_printable_name('Virgin Islands, U.s.').update_attribute(:dialing_prefix, 1340) 
    Country.find_by_printable_name('Wallis and Futuna').update_attribute(:dialing_prefix, 681) 
    Country.find_by_printable_name('Western Sahara').update_attribute(:dialing_prefix, 212) 
    Country.find_by_printable_name('Yemen').update_attribute(:dialing_prefix, 967) 
    Country.find_by_printable_name('Zambia').update_attribute(:dialing_prefix, 260) 
    Country.find_by_printable_name('Zimbabwe').update_attribute(:dialing_prefix, 263) 
  end

  def self.down
    remove_column :countries, :dialing_prefix
  end
end
