# FoodApp
SAE S5.01 : Application d'aide alimentaire pour les étudiants

Fonctionnalités :
    - Recherches de produits présents chez différentes enseignes avec une comparaison des prix entre les enseignes
    - Mise en favoris de certains produits afin d'être notifié des promotions le/les concernant(s)
    - Proposition intelligente de recettes en fonctions des produits sélectionnés/mis en favoris
    - Statistiques conernant vos habitudes d'achats, pour garder un suivi sur vos dépenses
    - Création et identification via un compte
    - Partager des recettes ou des bons plans à des connaissances
    - Informations concernant les produits afin de consommer des produits sains etgarder un oeil sur leurs provenances, calories apportées, etc 

Lien vers le trello : https://trello.com/b/LFk8NWPo/sae-app-food


Pour exécuter l'application après avoir cloné le code il faut rajouter un fichier .env à la racine du fichier avec ce contenu 
```SUPABASE_URL=https://ftuijeorywnqjgmqbcfk.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0dWlqZW9yeXducWpnbXFiY2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5MDQ4MDcsImV4cCI6MjA3NjQ4MDgwN30._iADlHpMD_9_5Y_tUnuaayvPwBEW2Dqg4osxUo7ox9U```

Et enfin modifier à la ligne 43 du fichier pubspec.yaml " -.env.example" en "- .env"
