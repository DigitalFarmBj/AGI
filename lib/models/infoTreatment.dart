class InfoTreatment {
  final String nom;

 
  final String number;
  final String pays;

  final String langue;
  final String filieres;
  InfoTreatment(
      {required this.nom,
     
      required this.pays,
      required this.number,
      required this.langue,
      required this.filieres,
     });
  Map<String, dynamic> toJson() => {
        'nom': nom,
       
        'pays': pays,
        'number': number,
        'langue': langue,
        'filieres': filieres,
        
      };
  @override
  String toString() {
    return "nom:$nom \n,pays:$pays \n,numero:$number \n, langue:$langue \n,Filieres:$filieres";
  }
}
