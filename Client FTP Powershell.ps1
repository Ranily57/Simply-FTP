#Fait par Ranily
Invoke-WebRequest http://herold.ddns.net/SFTPLogo/SimplyFTPLogo.ico -OutFile $HOME/SFTPLogo.ico

#Test

if (Get-Module -ListAvailable -Name Posh-SSH) {
#Création de la fonction Form
function GenerateForm {
	
	#Importation  de l'assembly
	[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
	[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
	
	#Création des différents objets du Form
	$form1 = New-Object System.Windows.Forms.Form
	#----------------
	#Composant fixe
	$label2 = New-Object System.Windows.Forms.Label
	$label1 = New-Object System.Windows.Forms.Label
	$label4 = New-Object System.Windows.Forms.Label
	$label3 = New-Object System.Windows.Forms.Label
	$versementbar = New-Object System.Windows.Forms.ProgressBar
	#----------------
	#Composant actif
	$connect = New-Object System.Windows.Forms.Button
	$filelist = New-Object System.Windows.Forms.ListBox
	$download = New-Object System.Windows.Forms.Button
	$textBox1 = New-Object System.Windows.Forms.TextBox
	$passwd = New-Object System.Windows.Forms.TextBox
	$server = New-Object System.Windows.Forms.TextBox
	$users = New-Object System.Windows.Forms.TextBox
	$toolTip1 = New-Object System.Windows.Forms.ToolTip
	$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
	#Création des évènements en cas d'interaction avec le formulaire
	#Seul la liste et les boutons sont scripter	

	$download_OnClick= 
	{
				#Création du form de sélection d'un emplacement
			[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
			[System.Windows.Forms.Application]::EnableVisualStyles()
			$browse = New-Object System.Windows.Forms.FolderBrowserDialog
			$browse.SelectedPath = "C:\"
			$browse.ShowNewFolderButton = $false
			$browse.Description = "Sélectionner un dossier"
		
				#Petite boucle:)
			$loop = $true
			while($loop)
			{
				if ($browse.ShowDialog() -eq "OK")
				{
				$loop = $false
				$entrypath = $browse.SelectedPath
					#Configuration des différentes variables
				$User = $users.text
				$Pass = $passwd.text
				$chemin =  $textBox1.text
				$EncryptedPass = ConvertTo-SecureString -String $Pass -asPlainText -Force
				$Credentials = New-Object System.Management.Automation.PSCredential($User,$EncryptedPass)
				$Server = $server.text
				$SFTPSession = New-SFTPSession -ComputerName $Server -Credential $Credentials		
					#Création de la session SFTP		
				Get-SFTPItem -SessionId $SFTPSession.SessionId -Path $chemin -Destination $entrypath
					#Message de fin pour dire que les fichiers ont bien était transférer
				[System.Windows.Forms.MessageBox]::Show("Fichier téléchargé !")
				Remove-SFTPSession -SFTPSession $SFTPSession
				
				} else
				{
					$res = [System.Windows.Forms.MessageBox]::Show("Voulez-vous continuer ou arrêter ?", "Sélectionner un dossier", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
					if($res -eq "Annuler")
					{
						
						return
					}
				}
			}
			$browse.SelectedPath
			$browse.Dispose()
		} 
	
	
	
	$handler_filelist_SelectedIndexChanged= 
	{
		$textBox1.text = $filelist.SelectedItem
		#Encore une configuration
	$User = $users.text
	$Pass = $passwd.text
	$chemin =  $textBox1.text
	$EncryptedPass = ConvertTo-SecureString -String $Pass -asPlainText -Force
	$Credentials = New-Object System.Management.Automation.PSCredential($User,$EncryptedPass)
	$Server = $server.text
	$SFTPSession = New-SFTPSession -ComputerName $Server -Credential $Credentials 

		#ouverture et lecture de la session SFTP
		try{
			$distantfiles = (Get-SFTPChildItem -SessionId $SFTPSession.SessionId -Path $chemin ).FullName
		$filelist.Items.Clear()
		$filelist.items.AddRange($distantfiles) 
		$download.Enabled = $True
		Remove-SFTPSession -SFTPSession $SFTPSession
		}catch{
			Remove-SFTPSession -SFTPSession $SFTPSession
		}
	
	}
	
	$connect_OnClick= 
	{
		$User = $users.text
		$Pass = $passwd.text
		$chemin =  $textBox1.text
		$EncryptedPass = ConvertTo-SecureString -String $Pass -asPlainText -Force
		$Credentials = New-Object System.Management.Automation.PSCredential($User,$EncryptedPass)
		$Server = $server.text
		$SFTPSession = New-SFTPSession -ComputerName $Server -Credential $Credentials

		$distantfiles = (Get-SFTPChildItem -SessionId $SFTPSession.SessionId -Path $chemin).FullName

		$filelist.Items.Clear()
		$filelist.items.AddRange($distantfiles)
		$download.Enabled = $True
		Remove-SFTPSession -SFTPSession $SFTPSession


	
	}
	$filelist_DragOver = [System.Windows.Forms.DragEventHandler]{
		if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) # $_ = [System.Windows.Forms.DragEventArgs]
		{
			$_.Effect = 'Copy'
		}
		else
		{
			$_.Effect = 'None'
		}
	}

		
	$filelist_DragDrop = [System.Windows.Forms.DragEventHandler]{
		#Configuration des différentes variables
		$User = $users.text
		$Pass = $passwd.text
		$chemin =  $textBox1.text
		$EncryptedPass = ConvertTo-SecureString -String $Pass -asPlainText -Force
		$Credentials = New-Object System.Management.Automation.PSCredential($User,$EncryptedPass)
		$Server = $server.text
		$i = 0
		$maxprogress = ($_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)).Count
		$versementbar.Maximum = $maxprogress


		foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) # $_ = [System.Windows.Forms.DragEventArgs]
		{
			$entrypath = $filename			
		#Création de la session SFTP
		
		$versementbar.Value = $i++
	$SFTPSession = New-SFTPSession -ComputerName $Server -Credential $Credentials
	Set-SFTPItem -SessionId $SFTPSession.SessionId -Path $entrypath -Destination $chemin
	$distantfiles = (Get-SFTPChildItem -SessionId $SFTPSession.SessionId -Path $chemin).FullName

		#Suppression et ajout des items dans la liste
	$filelist.Items.Clear()
	$filelist.items.AddRange($distantfiles)
	Remove-SFTPSession -SFTPSession $SFTPSession
		#Fermeture de la session SFTP
		}
		$versementbar.Value = 0
	}
	
	$OnLoadForm_StateCorrection=
	{
		$form1.WindowState = $InitialFormWindowState
	}
	
	
	#Génération de tout les composants du Form
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 474
	$System_Drawing_Size.Width = 688
	$form1.FormBorderStyle = 1
	$form1.ClientSize = $System_Drawing_Size
	$form1.DataBindings.DefaultDataSourceUpdateMode = 0
	$form1.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$HOME/SFTPLogo.ico")
	$form1.Name = "form1"
	$form1.Text = "Simply FTP"
	$form1.add_Load($handler_form1_Load)
	
	
	$connect.DataBindings.DefaultDataSourceUpdateMode = 0
	
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 462
	$System_Drawing_Point.Y = 133
	$connect.Location = $System_Drawing_Point
	$connect.Name = "connect"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 21
	$System_Drawing_Size.Width = 125
	$connect.Size = $System_Drawing_Size
	$connect.TabIndex = 12
	$connect.Text = "Connexion"
	$connect.UseVisualStyleBackColor = $True
	$connect.add_Click($connect_OnClick)
	
	$form1.Controls.Add($connect)
	
	$filelist.AllowDrop = $True
	$filelist.BorderStyle = 1
	$filelist.DataBindings.DefaultDataSourceUpdateMode = 0
	$filelist.FormattingEnabled = $True
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 17
	$System_Drawing_Point.Y = 223
	$filelist.Location = $System_Drawing_Point
	$filelist.Name = "filelist"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 236
	$System_Drawing_Size.Width = 656
	$filelist.Size = $System_Drawing_Size
	$filelist.TabIndex = 11
	
	$filelist.add_SelectedIndexChanged($handler_filelist_SelectedIndexChanged)
	
	$form1.Controls.Add($filelist)
	
	
	$download.DataBindings.DefaultDataSourceUpdateMode = 0
	$download.Enabled = $False
	$download.FlatStyle = 3
	
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 390
	$System_Drawing_Point.Y = 167
	$download.Location = $System_Drawing_Point
	$download.Name = "download"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 40
	$System_Drawing_Size.Width = 262
	$download.Size = $System_Drawing_Size
	$download.TabIndex = 10
	$download.Text = "Télécharger le dossier/fichier sélectionné"
	$download.UseVisualStyleBackColor = $True
	$download.add_Click($download_OnClick)
	
	$form1.Controls.Add($download)
	
	$label4.Anchor = 15
	$label4.DataBindings.DefaultDataSourceUpdateMode = 0
	
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 15
	$System_Drawing_Point.Y = 156
	$label4.Location = $System_Drawing_Point
	$label4.Name = "label4"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 18
	$System_Drawing_Size.Width = 341
	$label4.Size = $System_Drawing_Size
	$label4.TabIndex = 9
	$label4.Text = "Chemin Distant"
	$label4.TextAlign = 32
	
	$form1.Controls.Add($label4)
	
	$textBox1.BorderStyle = 1
	$textBox1.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 15
	$System_Drawing_Point.Y = 179
	$textBox1.Location = $System_Drawing_Point
	$textBox1.Name = "textBox1"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 20
	$System_Drawing_Size.Width = 341
	$textBox1.Size = $System_Drawing_Size
	$textBox1.TabIndex = 8
	
	$form1.Controls.Add($textBox1)
	
	$label3.Anchor = 15
	$label3.DataBindings.DefaultDataSourceUpdateMode = 0
	
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 348
	$System_Drawing_Point.Y = 63
	$label3.Location = $System_Drawing_Point
	$label3.Name = "label3"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 16
	$System_Drawing_Size.Width = 341
	$label3.Size = $System_Drawing_Size
	$label3.TabIndex = 7
	$label3.Text = "Mot de passe"
	$label3.TextAlign = 32
	
	$form1.Controls.Add($label3)
	
	$passwd.BorderStyle = 1
	$passwd.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 362
	$System_Drawing_Point.Y = 84
	$passwd.Location = $System_Drawing_Point
	$passwd.Name = "passwd"
	$passwd.PasswordChar = '*'
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 20
	$System_Drawing_Size.Width = 290
	$passwd.Size = $System_Drawing_Size
	$passwd.TabIndex = 6
	$passwd.UseSystemPasswordChar = $True
	
	$form1.Controls.Add($passwd)
	
	$label2.Anchor = 15
	$label2.DataBindings.DefaultDataSourceUpdateMode = 0
	
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 184
	$System_Drawing_Point.Y = 6
	$label2.Location = $System_Drawing_Point
	$label2.Name = "label2"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 19
	$System_Drawing_Size.Width = 341
	$label2.Size = $System_Drawing_Size
	$label2.TabIndex = 5
	$label2.Text = "IP/Nom de domaine"
	$label2.TextAlign = 32
	$label2.add_Click($handler_label2_Click)
	
	$form1.Controls.Add($label2)
	
	$label1.Anchor = 15
	$label1.DataBindings.DefaultDataSourceUpdateMode = 0
	
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 15
	$System_Drawing_Point.Y = 60
	$label1.Location = $System_Drawing_Point
	$label1.Name = "label1"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 19
	$System_Drawing_Size.Width = 341
	$label1.Size = $System_Drawing_Size
	$label1.TabIndex = 4
	$label1.Text = "Utilisateur"
	$label1.TextAlign = 32
	$label1.add_Click($handler_label1_Click)
	
	$form1.Controls.Add($label1)

	$versementbar.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 17
	$System_Drawing_Point.Y = 212
	$versementbar.Location = $System_Drawing_Point
	$versementbar.Name = "versementbar"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 10
	$System_Drawing_Size.Width = 655
	$versementbar.Size = $System_Drawing_Size
	$versementbar.TabIndex = 13
	$versementbar.Value = 0

	$form1.Controls.Add($versementbar)
	
	$server.BorderStyle = 1
	$server.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 15
	$System_Drawing_Point.Y = 28
	$server.Location = $System_Drawing_Point
	$server.Name = "server"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 20
	$System_Drawing_Size.Width = 637
	$server.Size = $System_Drawing_Size
	$server.TabIndex = 3
	$server.add_Click($handler_textBox2_Click)
	
	$form1.Controls.Add($server)
	
	$users.BorderStyle = 1
	$users.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 15
	$System_Drawing_Point.Y = 84
	$users.Location = $System_Drawing_Point
	$users.Name = "users"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 20
	$System_Drawing_Size.Width = 341
	$users.Size = $System_Drawing_Size
	$users.TabIndex = 2
	
	$form1.Controls.Add($users)
	
	$toolTip1.ToolTipTitle = "Ne peut que transférer un seul fichier"
	$toolTip1.add_Popup($handler_toolTip1_Popup)
	
	
	#Sauvegarde de la forme initial
	$InitialFormWindowState = $form1.WindowState
	#initialisation de la forme au démarrage du  form
	$form1.add_Load($OnLoadForm_StateCorrection)
	$filelist.Add_DragOver($filelist_DragOver)
	$filelist.Add_DragDrop($filelist_DragDrop)
	#Affichage du form
	$form1.ShowDialog()| Out-Null
	
	} 
	#Génération final du Form
	GenerateForm
	#Et voilas !

} else {

	$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
	[Security.Principal.WindowsBuiltInRole] "Administrator")


	if($isAdmin -eq "True"){
		Install-Module Posh-SSH
	}else{
    Add-Type -AssemblyName System.Windows.Forms
		$oReturn=[System.Windows.Forms.MessageBox]::Show("Le module Posh-SSH n'est pas installé, vous devez démarrer le script en mode Administrateur pour l'installer","Simply FTP",[System.Windows.Forms.MessageBoxButtons]::OK) 
    switch ($oReturn){
    "OK" {
        write-host "You pressed OK"
        # Enter some code
    } 
    "Cancel" {
        write-host "You pressed Cancel"
        # Enter some code
     
    }
}
}
}
	

