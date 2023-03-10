class Bank {
  String? slug;
  String? name;
  String? shortName;
  String? logo;
  String? providerCode;
  String? country;

  Bank(this.slug, this.name, this.shortName, this.logo, this.providerCode);
}

List<Bank> getBanks() {
  return <Bank>[
    Bank(
      'union-bank-of-nigeria-plc',
      'Union Bank Of Nigeria Plc',
      '',
      '',
      '',
    ),
    Bank('unity-bank-plc', 'Unity Bank Plc', '', '', ''),
    Bank('providus-bank', 'Providus Bank', '', '', ''),
    Bank('zenith-bank-plc', 'Zenith Bank Plc', '', '', ''),
    Bank('citibank-nigeria-limited', 'Citibank Nigeria Limited', '', '', ''),
    Bank('stanbic-ibtc-bank-ltd', 'Stanbic Ibtc Bank Ltd', '', '', ''),
    Bank('guaranty-trust-bank-plc', 'Guaranty Trust Bank Plc', '', '', ''),
    Bank('suntrust-bank-nigeria-limited', 'Suntrust Bank Nigeria Limited', '',
        '', ''),
    Bank('access-bank-plc', 'Access Bank Plc', '', '', ''),
    Bank('key-stone-bank', 'Key Stone Bank', '', '', ''),
    Bank(
        'first-bank-nigeria-limited', 'First Bank Nigeria Limited', '', '', ''),
    Bank('sterling-bank-plc', 'Sterling Bank Plc', '', '', ''),
    Bank('ecobank-nigeria-plc', 'Ecobank Nigeria Plc', '', '', ''),
    Bank('standard-chartered-bank-nigeria-ltd',
        'Standard Chartered Bank Nigeria Ltd', '', '', ''),
    Bank('heritage-banking-company-ltd', 'Heritage Banking Company Ltd', '', '',
        ''),
    Bank('globus-bank-limited', 'Globus Bank Limited', '', '', ''),
    Bank('titan-trust-bank-ltd', 'Titan Trust Bank Ltd', '', '', ''),
    Bank(
        'united-bank-for-africa-plc', 'United Bank For Africa Plc', '', '', ''),
    Bank('diamond-bank-plc', 'Diamond Bank Plc', '', '', ''),
    Bank('first-city-monument-bank-plc', 'First City Monument Bank Plc', '', '',
        ''),
    Bank('polaris-bank', 'Polaris Bank', '', '', ''),
    Bank('fidelity-bank-plc', 'Fidelity Bank Plc', '', '', ''),
    Bank('wema-bank-plc', 'Wema Bank Plc', '', '', '')
  ];
}
