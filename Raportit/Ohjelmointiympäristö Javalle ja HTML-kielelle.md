## Tehtävänanto:
Tehtävänä on tehdä oma Puppet moduuli. Valitsin moduulin aiheeksi ohjelmointi opiskelijoille suunnatun Java ohjelmointiympäristön sekä nettisivujen (HTML) kehitykseen tarkoitetun työkalun terminaalissa. Modulin ideana on, että se asentaa Java ohjelmointiympäristön (Eclipse) sekä valmiiksi konfiguroidun nettisivujen kehitystyökalun terminaalissa.

Tehtävä perustuu Tero Karvisen Palvelinten hallinta -kurssiin Haaga-Helia ammattikorkeakoulussa, joka löytyy osoitteesta: http://terokarvinen.com/2017/aikataulu-palvelinten-hallinta-ict4tn022-3-5-op-uusi-ops-loppusyksy-2017-p5

Käytössäni on kaksi konetta: Asus X555LJ sekä Haaga-Helian labraluokan kone. Molemmissa koneissa käytän Xubuntun live-USB -tikkua, käyttöjärjestelmäversiona 16.04.03 LTS. Koneiden tiedot:

![Asus](https://user-images.githubusercontent.com/15429934/32691476-f012d86a-c6ff-11e7-9056-6af4deee1788.png)

![labrakone](https://user-images.githubusercontent.com/15429934/32349009-600c8668-c01e-11e7-94f5-b1f84b26a75a.jpg)

Aloitin työvaiheen 5.12.2017 klo 12.15.

Avasin terminaalin ja annoin komennon ```setxkbmap fi``` asetaakseni suomalaisen näppäimistön. Latasin päivitykset ja asensin seuraavaksi Puppetin komennolla ```sudo apt-get update && sudo apt-get -y install puppet```. Seuraavaksi menin Puppetin hakemistoon komennolla ```cd /etc/puppet``` ja rakentamaan moduuliani. 

Menin modules -kansioon komennolla ```cd modules/``` ja loin uuden modulinkansion, jolle annoin nimeksi ```coding``` komennolla ```sudo mkdir coding```. Menin luotuun kansioon ja loin ```manifests``` ja ```templates``` -kansiot:

```cd coding/```

```sudo mkdir manifests templates```

/etc/puppet/coding/manifests/ -kansiossa loin ```init.pp``` tiedoston komennolla ```sudoedit init.pp``` ja kirjoitin tiedoston alkuun:

```
class coding {

}
```

Seuraavaksi lähdin rakentamaan moduulia. Kirjoitin ```init.pp``` -tiedostoon komennon:

```
        exec { 'apt-get update':
                command => '/usr/bin/apt-get update',
                refreshonly => true,
                }
```

Moduulin komento hakee päivitykset, kun moduuli muuttuu. Tällä varmistetaan, että moduuliin tarvittavat paketit pysyvät ajantasalla. Seuraavaksi lähdin asentamaan Eclipsea ja siihen Java ohjelmointi ympäristöä. Kirjoitin tiedostoon:

```
        package { openjdk-8-jre:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }

        package { eclipse:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }
                
        exec { 'OpenEclipse':
                command => '/usr/bin/eclipse &',
                require => Package['eclipse'],
                }
            
```

Laitoin tiedostoon, että paketit voidaan asentaa live USB -tikulle ja että asennetaan paketit vasta kun päivitykset on haettu sekä avaa Eclipsen. &-merkki exec -komennossa, joka avaa Eclipsen tarkoittaa sitä että moduulia ajattaessa se ei jää pyörimään loputtomiin. Kokeilin seuraavaksi modulin toimivuutta. Tallensin tiedoston ja annoin komennon:

```sudo puppet apply --modulepath modules/ -e 'class {"coding":}'```

Eclipse asentui onnistuneesti ja aukesi hetken päästä ja se kysyi mihin paikkaan koodaustyöt tallennetaan:

![eclipseopen](https://user-images.githubusercontent.com/15429934/33797798-2142d37e-dd06-11e7-9516-5685078cd265.png)

Klikkasin OK ja Eclipsen työpöytä aukesi:

![eclipseopenokafter](https://user-images.githubusercontent.com/15429934/33797800-2406cd5e-dd06-11e7-9008-3f584db73e72.png)

Suljin ohjelman ja lähdin muokkaamaan moduulia lisää. Seuraavaksi ryhdyin tekemään nettisivujen asetuksia moduuliin. Kirjoitin moduuliin, että se asentaa Apachen, käynnistää apache -demonin uudelleen muutosten tullessa ja luo käyttäjän kotisivuhakemiston (public_html) sekä laittaa käyttäjän kotisivut toimimaan. Katsoin ohjeita tähän [Simo Suomisen nettisvuilta.](http://simosuominen.com/tag/github/)

```
package { apache2:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }

        service { 'apache2':
                ensure => 'true',
                enable => true,
                require => Package['apache2'],
                }

        file { '/home/xubuntu/public_html':
                ensure => 'directory',
                owner => 'xubuntu',
                mode => '0644',
                }
                
        file { '/etc/apache2/mods-enabled/userdir.load':
                ensure => 'link',
                target => '/etc/apache2/mods-available/userdir.load',
                notify => Service["apache2"],
                require => Package["apache2"],
                }

        file { '/etc/apache2/mods-enabled/userdir.conf':
                ensure => 'link',
                target => '/etc/apache2/mods-available/userdir.conf',
                notify => Service["apache2"],
                require => Package["apache2"],
                }

```

Tallensin moduulin ja ajoin sen. Virheitä ei tullut ja Apache asentui. Kokeilin käyttäjän kotihakemiston toimivuutta luomalla sinne index.html tiedoston. Menin kotihakemistoon ja loin index.html -tiedoston komennoilla:

```cd```

```cd public_html```

```nano index.html```

Kirjoitin tiedostoon validia HTML -kieltä [W3Schoolsin sivuilta löytyvällä esimerkillä](https://www.w3schools.com/html/html_intro.asp) ja kirjoitin selaimeen ```localhost/~xubuntu```, jotta voin varmistaa, että käyttäjän nettisivut oikeasti toimivat.

![htmlexample](https://user-images.githubusercontent.com/15429934/33798077-4fe83e0e-dd0a-11e7-8d4f-989caac33fe5.png)

Käyttäjän kotisivut toimivat oikein.

Seuraavaksi ryhdyin muokkaamaan index.html tiedostoa enemmän informatiiviseksi moduulin käyttäjää varten. Loin seuraavanlaisen index.html tiedoston:

```
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>HTML coding</title>
</head>

<body>
Code Works!
</body>

</html>
```

Seuraavaksi siirsin tämän tiedoston modulini ```templates``` -kansioon komennolla:

```sudo mv index.html /etc/puppet/modules/coding/templates```

Muutin vielä tiedoston nimeä, jotta Puppet osaa lukea templateja oikein:

```sudo mv index.html index.html.erb```

Seuraavaksi muokkasin lisää modulini init.pp -tiedostoa komennolla:

```sudoedit /etc/puppet/modules/coding/manifests/init.pp```

Lisäsin seuraavaksi komennon, että se luo käyttäjälle index.html tiedoston templaten pohjalta:

```
        file { '/home/xubuntu/public_html/index.html':
                content => template('coding/index.html.erb'),
                require => File['/home/xubuntu/public_html'],
                owner => 'xubuntu',
                mode => '0644',
                }
```

Komento hakee ```templates``` -kansiosta sinne luomanani ```index.html``` -tiedoston käyttäjän ```public_html``` -kansioon. Modulini näyttää nyt tältä:

```
class coding {
      
        exec { 'apt-get update':
                command => '/usr/bin/apt-get update',
                refreshonly => true,
                }
        package { apache2:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }

        service { 'apache2':
                ensure => 'true',
                enable => true,
                require => Package['apache2'],
                }

        file { '/home/xubuntu/public_html':
                ensure => 'directory',
                owner => 'xubuntu',
                mode => '0644',
                }
                
        file { '/etc/apache2/mods-enabled/userdir.load':
                ensure => 'link',
                target => '/etc/apache2/mods-available/userdir.load',
                notify => Service["apache2"],
                require => Package["apache2"],
                }

        file { '/etc/apache2/mods-enabled/userdir.conf':
                ensure => 'link',
                target => '/etc/apache2/mods-available/userdir.conf',
                notify => Service["apache2"],
                require => Package["apache2"],
                }


        file { '/home/xubuntu/public_html/index.html':
                content => template('coding/index.html.erb'),
                require => File['/home/xubuntu/public_html'],
                owner => 'xubuntu',
                mode => '0644',
                }
                
        package { openjdk-8-jre:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }

        package { eclipse:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }
                
        exec { 'OpenEclipse':
                command => '/usr/bin/eclipse &',
                require => Package['eclipse'],
                }
}                
  
```

Tree ohjelman avulla Puppet hakemistoni näyttää tältä:

![treepuppetfirst](https://user-images.githubusercontent.com/15429934/33798276-6cecef92-dd0d-11e7-88f4-79a44bab09a7.png)

Lopuksi asensin gitin ja lisäsin moduulini [GitHubiini](https://github.com/marrkus/coding), josta voin helposti jatkaa modulini tekoa myöhemmin ja lopetin tältä erää.

Lopetin työvaiheen klo 17.03.

### Modulin jatkaminen

Aloitin työvaiheen 8.12.2017 klo 16.02.

Ryhdyin muokkaamaan moduliani sekä asensin gitin. Cloonaasin Gtihubini repositoryn, jossa modulini on komennolla:

```git clone https://github.com/marrkus/coding.git```

Lisäsin modulini Puppet hakemistoon:

```cd coding/modules```

```sudo cp -r coding/ /etc/puppet/modules/```

Lähdin seuraavaksi muokkamaan moduliani:

```sudoedit /etc/puppet/modules/coding/manifests/init.pp```

Lisäsin moduuliin ```/etc/skel``` hakemistoon luomani ```index.html```, jotta se kopioituu kaikille uusille käyttäjille. Tiedostoa ```/etc/skel```:iin lisättäessä tulee antaa pääkäyttäjän oikeudet:

```
           file { '/etc/skel/index.html':
                ensure => 'file',
                content => template('coding/index.html.erb'),
                owner => 'root',
                group => 'root',
                mode => '0644',
                }
```

Ajoin moduulin ja tiedosto luotiin ```/etc/skel```:iin.

Seuraavaksi lähdin katsomaan Javan ohjelmointikieltä. Ideana olisi, että modulin käyttäjä saa valmiin Java koodin, jotta voisi helposti lähteä jatkamaan Java ohjelmointia. Löysin netistä valmiita [Java koodeja](https://www.cs.utexas.edu/~scottm/cs307/codingSamples.htm). Latasin yksinkertaisen Hello World -Java koodin. Downloads -kansiosta siirsin sen Puppet modulini templates -kansioon:

```sudo mv Main.java /etc/puppet/modules/coding/templates```

Muokkasin vielä Java-tiedoston nimen Puppetin templateja varten:

```sudo mv Main.java Main.java.erb```

Seuraavaksi muokkasin moduliani. Lisäsin myös tämän tiedoston ```/etc/skel```:iin, jotta kaikki uudet käyttäjät saavat tämän tiedoston:

```
           file { '/etc/skel/Main.java':
                ensure => 'file',
                content => template('coding/Main.java.erb'),
                owner => 'root',
                group => 'root',
                mode => '0644',
                }
```

Koko modulini näyttää nyt tältä:

```
class coding {

        exec { 'apt-get update':
                command => '/usr/bin/apt-get update',
                refreshonly => true,
                }

        package { apache2:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }

        service { 'apache2':
                ensure => 'true',
                enable => true,
                require => Package['apache2'],
                }

        file { '/home/xubuntu/public_html':
                ensure => 'directory',
                owner => 'xubuntu',
                mode => '0644',
                }

        file { '/home/xubuntu/public_html/index.html':
                content => template('coding/index.html.erb'),
                require => File['/home/xubuntu/public_html'],
                owner => 'xubuntu',
                mode => '0644',
                }

        file { '/etc/apache2/mods-enabled/userdir.load':
                ensure => 'link',
                target => '/etc/apache2/mods-available/userdir.load',
                notify => Service["apache2"],
                require => Package["apache2"],
                }

        file { '/etc/apache2/mods-enabled/userdir.conf':
                ensure => 'link',
                target => '/etc/apache2/mods-available/userdir.conf',
                notify => Service["apache2"],
                require => Package["apache2"],
                }

        package { openjdk-8-jre:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }

        package { eclipse:
                require => Exec['apt-get update'],
                ensure => 'installed',
                allowcdrom => 'true',
                }

        file { '/etc/skel/Main.java':
                ensure => 'file',
                content => template('coding/Main.java.erb'),
                owner => 'root',
                group => 'root',
                mode => '0644',
                }

        file { '/etc/skel/index.html':
                ensure => 'file',
                content => template('coding/index.html.erb'),
                owner => 'root',
                group => 'root',
                mode => '0644',
                }

        exec { 'OpenEclipse':
                command => '/usr/bin/eclipse &',
                require => Package['eclipse'],
                }
}

```

Lisäsin modulin kokonaisuudessaan GitHubiin ja aloitin Linuxin käytön puhtaalta pöydältä sekä pidin 15 minuutin tauon.

Seuraavaksi lähdin tekemään bash scriptiä moduliani varten. Menin kotihakemistoon ja loin uuden tiedoston:

```nano codingstart.sh```

Kirjoitin bashin sheabangin tiedoston ensimmäselle riville:

```#!/bin/bash```

Tavoitteena on, että scripti asettaa suomenkielisen näppäimistön, hakee päivitykset, asentaa puppetin ja gitin ja ajaa modulini.

Kirjoitin tiedostoon seuraavat komennot:

```setxkbmap fi```

```sudo apt-get update```

```sudo apt-get -y install puppet git```

```git clone https://github.com/marrkus/coding.git```

```cd coding/modules```

```sudo cp -r coding/ /etc/puppet/modules/```

```cd /etc/puppet/```

```sudo puppet apply --modulepath modules/ -e 'class {"coding":}'```

Tallensin scriptin ja kokeilin sitä komennolla:

```bash codingstart```

Scripti onnistuneesti ajoi modulini:

![scripttest](https://user-images.githubusercontent.com/15429934/33798736-fab7e324-dd15-11e7-87ed-52a3bad62e90.png)

Muokkasin vielä scriptiä, että se avaa käyttäjän localhostin ja ohjeita nettisivujen kehitystä varten sekä Eclipsen käyttöohje sivulle. Lisäksi scripti avaa suoraan ```index.html``` tiedoston, jotta nettisivuja voi nopeasti muokata.

```
firefox -new-tab -url https://www.tutorialspoint.com/eclipse/eclipse_create_java_project.htm
firefox -new-tab -url https://www.w3schools.com/html/html_elements.asp
firefox -new-tab -url localhost/~$USER
nano /home/xubuntu/public_html/index.html
```

Kokonaisuudessaan scripti näyttää nyt tältä:

```
#!/bin/bash
setxkbmap fi
sudo apt-get update
sudo apt-get -y install puppet git

git clone https://github.com/marrkus/coding.git

cd coding/modules
sudo cp -r coding/ /etc/puppet/modules/
cd /etc/puppet/
sudo puppet apply --modulepath modules/ -e 'class {"coding":}'

firefox -new-tab -url https://www.tutorialspoint.com/eclipse/eclipse_create_java_project.htm
firefox -new-tab -url https://www.w3schools.com/html/html_elements.asp
firefox -new-tab -url localhost/~$USER
nano /home/xubuntu/public_html/index.html


echo "***************************"
echo " "
echo "Ready to use"
echo " "
echo "***************************"
```

![codingstartsh](https://user-images.githubusercontent.com/15429934/33798774-a5f8bd12-dd16-11e7-90c7-828912f9133a.png)

Ajoin scriptin vielä uudestaan, jolloin sain lopputulokseksi tällaisen näkymän:

![codingscriptfinish](https://user-images.githubusercontent.com/15429934/33798801-29fe6544-dd17-11e7-8422-30b439154a92.png)

Lisäsin valmiin scriptini GitHubiin ja ohjeet sitä varten löytävät myös [GitHubistani](https://github.com/marrkus/coding).

Lopetin tehtävän klo 21.37.

## Lähteet

Apache Puppet moduuli: http://simosuominen.com/tag/github/

HTML esimerkki: https://www.w3schools.com/html/html_intro.asp

Puppet ohjeita:

https://docs.puppet.com/puppet/3.8/

https://www.puppetcookbook.com/

Java koodeja: https://www.cs.utexas.edu/~scottm/cs307/codingSamples.htm

Eclipse ohjeita: https://www.tutorialspoint.com/eclipse/eclipse_create_java_project.htm

HTML ohjeita: https://www.w3schools.com/html/html_elements.asp

Modulini: https://github.com/marrkus/coding




