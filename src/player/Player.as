package player
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Screen;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	
	public class Player extends Sprite
	{
		[Embed(source="images/play_btn_icon_45x45.png")]   
		private var PlayBtnClass:Class;
		
		[Embed(source="images/stop_btn_icon_45x45.png")]  
		private var StopBtnClass:Class;
		
		[Embed(source="images/sound_btn_icon_30x30.png")]  
		private var SoundBtnClass:Class;
		
		[Embed(source="images/mute_btn_icon_30x30.png")]  
		private var MuteBtnClass:Class;
		
		[Embed(source="images/play_btn_big.png")]  
		private var PlayBigBtnClass:Class;
		
		[Embed(source="images/fullScreen.png")]  
		private var FullScreenBtnClass:Class;
		
		[Embed(source="images/escFullScreen.png")]  
		private var EscFullScreenBtnClass:Class;
		
		private var _vPlayerBar:Sprite = new Sprite();
		private var _spBg:Shape = new Shape();
		private var _bmPlayBtn:Bitmap = new PlayBtnClass();
		private var _bmStopBtn:Bitmap = new StopBtnClass();
		private var _playBtn:Sprite = new Sprite();
		private var _stopBtn:Sprite = new Sprite();
		private var _videoSilderBnakSp:Sprite = new Sprite();
		private var _videoSilderMiddleSp:Shape = new Shape();
		private var _videoSilderFrontSp:Shape = new Shape();
		private var _videoSilderCircleSp:Shape = new Shape();
		private var _sumDurationText:TextField = new TextField();
		private var _currentDurationText:TextField = new TextField();
		private var _bmSoundBtn:Bitmap = new SoundBtnClass();
		private var _bmMuteBtn:Bitmap = new MuteBtnClass();
		private var _soundBtn:Sprite = new Sprite();
		private var _muteBtn:Sprite = new Sprite();
		private var _soundSilderBnakSp:Sprite = new Sprite();
		private var _soundSilderFrontSp:Shape = new Shape();
		private var _soundSilderCircleSp:Sprite = new Sprite();
		private var _myload:Loader=new Loader();
		private var _bmBigPlayBtn:Bitmap = new PlayBigBtnClass();
		private var _bigPlayBtn:Sprite = new Sprite();
		private var _bmFullScreenBtn:Bitmap = new FullScreenBtnClass();
		private var _fullCcreenBtn:Sprite = new Sprite();
		private var _bmEscFullScreenBtn:Bitmap = new EscFullScreenBtnClass();
		private var _escFullCcreenBtn:Sprite = new Sprite();
		
		private var  _mespri:MediaPlayerSprite = new MediaPlayerSprite();
		private var _vp:MediaPlayer = _mespri.mediaPlayer;
		
		private var _w:Number;
		private var _h:Number;
		private var _mainWindow:VideoPlayer;
		private var _videoPath:String;
		
		public function Player(w:Number, h:Number, mainWimdow:VideoPlayer, videoPath:String)
		{
			_w = w;
			_h = h;
			_mainWindow = mainWimdow;
			_videoPath = videoPath;
			
			addEventListener(Event.ADDED_TO_STAGE, addStageComplete); 
		}
		
		private function addStageComplete(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addStageComplete);
			
			initStage();
			createPlayer();
			createVPlayerBar();
			
			resize(_w, _h);
		}
		
		private function initStage():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		private function createVPlayerBar():void
		{
			//播放控制条
			addChild(_vPlayerBar);
			_vPlayerBar.y = stage.stageHeight - 50;
			
			//播放控制条背景
			_vPlayerBar.addChild(_spBg);
			_spBg.graphics.beginFill(0x363636, 0.5);
			_spBg.graphics.drawRect(0,0, stage.stageWidth, 50);
			_spBg.graphics.endFill();
			
			//播放按钮
			_playBtn.graphics.beginBitmapFill(_bmPlayBtn.bitmapData);
			_playBtn.graphics.drawRect(0,0,45,45);
			_playBtn.graphics.endFill();
			_playBtn.x = 10;
			_playBtn.y = (_vPlayerBar.height - _playBtn.height) / 2 ;
			_playBtn.visible = false;
			_playBtn.addEventListener(MouseEvent.CLICK, startPlayHandler);
			_vPlayerBar.addChild(_playBtn);
			
			//暂停按钮
			_stopBtn.graphics.beginBitmapFill(_bmStopBtn.bitmapData);
			_stopBtn.graphics.drawRect(0,0,45,45);
			_stopBtn.graphics.endFill();
			_stopBtn.x = 10;
			_stopBtn.y = (_vPlayerBar.height - _stopBtn.height) / 2 ;
			_stopBtn.visible = true;
			_stopBtn.addEventListener(MouseEvent.CLICK, stopPlayHandler);
			_vPlayerBar.addChild(_stopBtn);
			
			//视频进度条背景
			_videoSilderBnakSp.graphics.beginFill(0x595959, 1);
			_videoSilderBnakSp.graphics.drawRect(0,0,stage.stageWidth * 0.6, 4);
			_videoSilderBnakSp.graphics.endFill();
			_videoSilderBnakSp.x = _bmStopBtn.x + _bmStopBtn.width + 30;
			_videoSilderBnakSp.y  = (_vPlayerBar.height - _videoSilderBnakSp.height) / 2 ;
			_videoSilderBnakSp.addEventListener(MouseEvent.CLICK, videoSilderClickHandler);
			_vPlayerBar.addChild(_videoSilderBnakSp);
			
			//视频进度条缓冲背景
			_videoSilderMiddleSp.graphics.beginFill(0x7d7d7d, 1);
			_videoSilderMiddleSp.graphics.drawRect(0,0,400, 4);
			_videoSilderMiddleSp.graphics.endFill();
			_videoSilderMiddleSp.x = _videoSilderBnakSp.x;
			_videoSilderMiddleSp.y  = (_vPlayerBar.height - _videoSilderBnakSp.height) / 2 ;
			_vPlayerBar.addChild(_videoSilderMiddleSp);
			
			//视频进度条播放进度
			_videoSilderFrontSp.graphics.beginFill(0x1894ee, 1);
			_videoSilderFrontSp.graphics.drawRect(0,0,2, 4);
			_videoSilderFrontSp.graphics.endFill();
			_videoSilderFrontSp.x = _videoSilderBnakSp.x;
			_videoSilderFrontSp.y  = (_vPlayerBar.height - _videoSilderFrontSp.height) / 2 ;
			_vPlayerBar.addChild(_videoSilderFrontSp);
			
			//视频进度条播放按钮
			_videoSilderCircleSp.graphics.beginFill(0x1894ee, 0.5);
			_videoSilderCircleSp.graphics.drawCircle(0,0,8);
			_videoSilderCircleSp.graphics.endFill();
			_videoSilderCircleSp.graphics.beginFill(0x1894ee, 1);
			_videoSilderCircleSp.graphics.drawCircle(0,0,5);
			_videoSilderCircleSp.graphics.endFill();
			_videoSilderCircleSp.x = _videoSilderFrontSp.x + _videoSilderFrontSp.width;
			_videoSilderCircleSp.y  = _videoSilderFrontSp.y + 2;
			_vPlayerBar.addChild(_videoSilderCircleSp);
			
			//视频总时间文本
			_sumDurationText.text = "00:00  / ";
			_sumDurationText.width = 40;
			_sumDurationText.height=20;
			_sumDurationText.x = _videoSilderBnakSp.x + _videoSilderBnakSp.width + 10;
			_sumDurationText.y = (_vPlayerBar.height - _sumDurationText.height) / 2 ;
			_sumDurationText.multiline = false;              
			_sumDurationText.type = TextFieldType.INPUT;    
			_sumDurationText.wordWrap = false;
			_sumDurationText.textColor = 0xffffff;            
			SetTextFormat(_sumDurationText);
			_vPlayerBar.addChild(_sumDurationText);
			
			//视频当前播放时间文本
			_currentDurationText.text = "00:00";
			_currentDurationText.width = 40;
			_currentDurationText.height=20;
			_currentDurationText.x = _sumDurationText.x + _sumDurationText.width;
			_currentDurationText.y = (_vPlayerBar.height - _currentDurationText.height) / 2 ;
			_currentDurationText.multiline = false;                
			_currentDurationText.type = TextFieldType.INPUT;      
			_currentDurationText.wordWrap = false;
			_currentDurationText.textColor = 0xffffff;            
			SetTextFormat(_currentDurationText);
			_vPlayerBar.addChild(_currentDurationText);
			
			//音量图标
			_soundBtn.graphics.beginBitmapFill(_bmSoundBtn.bitmapData);
			_soundBtn.graphics.drawRect(0,0,30,30);
			_soundBtn.graphics.endFill();
			_soundBtn.x = _currentDurationText.x + _currentDurationText.width + 50;
			_soundBtn.y = (_vPlayerBar.height - _bmSoundBtn.height) / 2 ;
			_soundBtn.visible = true;
			_soundBtn.addEventListener(MouseEvent.CLICK, muteHandler);
			_vPlayerBar.addChild(_soundBtn);
			
			//静音图标
			_muteBtn.graphics.beginBitmapFill(_bmMuteBtn.bitmapData);
			_muteBtn.graphics.drawRect(0,0,30,30);
			_muteBtn.graphics.endFill();
			_muteBtn.x = _currentDurationText.x + _currentDurationText.width + 50;
			_muteBtn.y = (_vPlayerBar.height - _muteBtn.height) / 2 ;
			_muteBtn.visible = false;
			_muteBtn.addEventListener(MouseEvent.CLICK, openSoundHandler);
			_vPlayerBar.addChild(_muteBtn);
			
			//音量条背景
			_soundSilderBnakSp.graphics.beginFill(0x595959, 1);
			_soundSilderBnakSp.graphics.drawRect(0,0,100, 4);
			_soundSilderBnakSp.graphics.endFill();
			_soundSilderBnakSp.x = _soundBtn.x + _soundBtn.width + 10;
			_soundSilderBnakSp.y  = (_vPlayerBar.height - _soundSilderBnakSp.height) / 2 ;
			_soundSilderBnakSp.addEventListener(MouseEvent.CLICK, soundSilderClickHandler);
			_vPlayerBar.addChild(_soundSilderBnakSp);
			
			//音量条前景
			_soundSilderFrontSp.graphics.beginFill(0x1894ee, 1);
			_soundSilderFrontSp.graphics.drawRect(0,0,50, 4);
			_soundSilderFrontSp.graphics.endFill();
			_soundSilderFrontSp.x = _soundSilderBnakSp.x;
			_soundSilderFrontSp.y  = (_vPlayerBar.height - _soundSilderFrontSp.height) / 2 ;
			_vPlayerBar.addChild(_soundSilderFrontSp);
			
			//音量条按钮
			_soundSilderCircleSp.graphics.beginFill(0x1894ee, 0);
			_soundSilderCircleSp.graphics.drawCircle(0,0,15);
			_soundSilderCircleSp.graphics.endFill();
			_soundSilderCircleSp.graphics.beginFill(0x1894ee, 1);
			_soundSilderCircleSp.graphics.drawCircle(0,0,5);
			_soundSilderCircleSp.graphics.endFill();
			_soundSilderCircleSp.x = _soundSilderFrontSp.x + _soundSilderFrontSp.width;
			_soundSilderCircleSp.y = _soundSilderFrontSp.y + 2;
			_soundSilderCircleSp.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_soundSilderCircleSp.addEventListener(MouseEvent.MOUSE_UP, soundSilderCircleSpMouseUpHandler);
			_vPlayerBar.addChild(_soundSilderCircleSp);
			
			//视频缓冲动画
			var url:URLRequest=new URLRequest("images/loading.swf");
			_myload.load(url);
			_myload.x = (stage.stageWidth - 400) / 2;
			_myload.y = (stage.stageHeight - 400) / 2;
			addChild(_myload);
			
			//视频中间的打的播放按钮
			_bigPlayBtn.graphics.beginBitmapFill(_bmBigPlayBtn.bitmapData);
			_bigPlayBtn.graphics.drawRect(0,0,100,100);
			_bigPlayBtn.graphics.endFill();
			_bigPlayBtn.x = (stage.stageWidth - _bigPlayBtn.width) / 2;
			_bigPlayBtn.y = (stage.stageHeight - _bigPlayBtn.height) / 2 ;
			_bigPlayBtn.visible = false;
			_bigPlayBtn.addEventListener(MouseEvent.CLICK, startPlayHandler);
			addChild(_bigPlayBtn);
			
			//视频全屏按钮
			_fullCcreenBtn.graphics.beginBitmapFill(_bmFullScreenBtn.bitmapData);
			_fullCcreenBtn.graphics.drawRect(0,0,30,30);
			_fullCcreenBtn.graphics.endFill();
			_fullCcreenBtn.x = _vPlayerBar.width - 50;
			_fullCcreenBtn.y = (_vPlayerBar.height - _fullCcreenBtn.height) / 2 ;
			_fullCcreenBtn.visible = true;
			_fullCcreenBtn.addEventListener(MouseEvent.CLICK, fullScreenHandler);
			_vPlayerBar.addChild(_fullCcreenBtn);
			
			//视频退出全屏按钮
			_escFullCcreenBtn.graphics.beginBitmapFill(_bmEscFullScreenBtn.bitmapData);
			_escFullCcreenBtn.graphics.drawRect(0,0,30,30);
			_escFullCcreenBtn.graphics.endFill();
			_escFullCcreenBtn.x = _vPlayerBar.width - 50;
			_escFullCcreenBtn.y = (_vPlayerBar.height - _escFullCcreenBtn.height) / 2 ;
			_escFullCcreenBtn.visible = false;
			_escFullCcreenBtn.addEventListener(MouseEvent.CLICK, escFullScreenHandler);
			_vPlayerBar.addChild(_escFullCcreenBtn);
			
		}
		
		private function fullScreenHandler(e:MouseEvent):void
		{
			_fullCcreenBtn.visible = false;
			_escFullCcreenBtn.visible = true;
			_mainWindow.maximize();
		}
		
		private function escFullScreenHandler(e:MouseEvent):void
		{
			_escFullCcreenBtn.visible = false;
			_fullCcreenBtn.visible = true;
			_mainWindow.restore();
		}
		
		private function mouseDownHandler(e:MouseEvent):void
		{
			var rec:Rectangle = new Rectangle(_soundSilderBnakSp.x, _soundSilderBnakSp.y + 2, _soundSilderBnakSp.width, _soundSilderBnakSp.height - 4);
			_soundSilderCircleSp.startDrag(false, rec);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			addEventListener(MouseEvent.MOUSE_UP, soundSilderCircleSpMouseUpHandler);
		}
		
		private function mouseMove(e:MouseEvent):void
		{
			var p:Point = new Point(_soundSilderCircleSp.x, _soundSilderCircleSp.y);
			var gp:Point = _soundSilderBnakSp.globalToLocal(p);
			
			_soundSilderFrontSp.width = gp.x;
			
			if(gp.x > -1)
			{
				_vp.volume = gp.x
				_volume = gp.x;
				
				if(_vp.volume == 0)
				{
					_vp.muted = true;
					_soundBtn.visible = false;
					_muteBtn.visible = true;
					
				}
				else
				{
					_vp.muted = false;
					_soundBtn.visible = true;
					_muteBtn.visible = false;
				}
			}
			
			//trace("_soundSilderCircleSp.x = " + _soundSilderCircleSp.x, "gp = " + gp.x, "mouseX = " + mouseX);
		}
		
		private function soundSilderCircleSpMouseUpHandler(e:MouseEvent):void
		{
			_soundSilderCircleSp.stopDrag();
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			removeEventListener(MouseEvent.MOUSE_UP, soundSilderCircleSpMouseUpHandler);
		}
		
		private function startPlayHandler(e:MouseEvent):void
		{
			if(_vp.paused)
			{
				_playBtn.visible = false;
				_stopBtn.visible = true;
				_vp.play();
			}
			
		}
		
		
		private function reload():void
		{
			var meRes:MediaResourceBase = new URLResource(_videoPath);
			_mespri.resource = meRes;
		}
		
		private function stopPlayHandler(e:MouseEvent):void
		{
			if(_vp.playing)
			{
				_playBtn.visible = true;
				_stopBtn.visible = false;
				_vp.pause();
			}
		}
		
		private var _duration:Number = 0;
		private function videoSilderClickHandler(e:MouseEvent):void
		{
			var videoSilderSeek:Number = (_duration / _videoSilderBnakSp.width) * _videoSilderBnakSp.mouseX;
			_vp.seek(videoSilderSeek);
		}
		
		private var _volume:Number = 0;
		private function soundSilderClickHandler(e:MouseEvent):void
		{
			//trace(_soundSilderBnakSp.mouseX);
			_volume = _soundSilderBnakSp.mouseX;
			_soundSilderFrontSp.width = _volume;
			_soundSilderCircleSp.x = _soundSilderFrontSp.x + _soundSilderFrontSp.width;
			_vp.volume = _volume;
			
			if(_volume == 0)
			{
				_soundBtn.visible = false;
				_muteBtn.visible = true;
			}
			else
			{
				_soundBtn.visible = true;
				_muteBtn.visible = false;
			}
		}
		
		private function openSoundHandler(e:MouseEvent):void
		{
			if(_vp.muted)
			{
				_soundBtn.visible = true;
				_muteBtn.visible = false;
				
				if(_volume == 0)
				{
					_volume = 50;
				}
				
				_vp.volume = _volume;
				_vp.muted = false;
				_soundSilderFrontSp.width = _volume;
				_soundSilderCircleSp.x = _soundSilderFrontSp.x + _soundSilderFrontSp.width;
			}
		}
		
		private function muteHandler(e:MouseEvent):void
		{
			if(!_vp.muted)
			{
				_soundBtn.visible = false;
				_muteBtn.visible = true;
				_vp.volume = 0;
				_vp.muted = true;
				
				_soundSilderFrontSp.width = 0;
				_soundSilderCircleSp.x = _soundSilderFrontSp.x + _soundSilderFrontSp.width;
			}
			
		}
		
		private function SetTextFormat(textFiled:TextField):void
		{
			var textFormat:TextFormat = new TextFormat;
			textFormat.bold = true;
			
			textFiled.setTextFormat(textFormat);
		}
		
		/**
		 *更新所有元素大小 
		 * 
		 */		
		private function updateControlSize():void
		{
			
		}
		
		private function  createPlayer():void
		{
			if(!_videoPath)
			{
				return;
			}
			
			addChild(_mespri);
			_mespri.addEventListener(MouseEvent.DOUBLE_CLICK, mespriDoubleClickHandler);
			_mespri.addEventListener(MouseEvent.MOUSE_OVER, mespriMouseOverHandler);
			_mespri.addEventListener(MouseEvent.MOUSE_OUT, mespriMouseOutHandler);
			
			var meRes:URLResource = new URLResource(_videoPath);
			_mespri.resource = meRes;
			_mespri.width = stage.stageWidth;
			_mespri.height = stage.stageWidth;
			_vp.volume = 50;
			_vp
			_vp.addEventListener(MediaErrorEvent.MEDIA_ERROR, errorHandler);
			_vp.addEventListener(TimeEvent.DURATION_CHANGE, vpDurationChangeHandler);
			_vp.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, vpCurrentTimeChangeHandler);
			_vp.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, mediaplayerStateChangeHandler);
		}
		
		private function errorHandler(e:MediaErrorEvent):void
		{
			trace(e);
		}
		
		private function mespriDoubleClickHandler(e:MouseEvent):void
		{
			if(_vp.playing)
			{
				_vp.pause();
				_playBtn.visible = true;
				_stopBtn.visible = false;
			}
			else if(_vp.paused)
			{
				_vp.play();
				_playBtn.visible = false;
				_stopBtn.visible = true;
			}
		}
		
		protected var _timeoutId:uint;
		private function mespriMouseOverHandler(e:MouseEvent):void
		{
			if(_timeoutId)
			{
				clearTimeout(_timeoutId);
			}
			
			showControlBar(true);
		}

		private function mespriMouseOutHandler(e:MouseEvent):void
		{
			if(_vp.state != "paused" && _vp.state != "buffering")
			{
				_timeoutId = setTimeout(function(){
					showControlBar(false);
					if(_timeoutId)
					{
						clearTimeout(_timeoutId);
					}
				}, 2000);
			}
		}
		
		private function mediaplayerStateChangeHandler(e:MediaPlayerStateChangeEvent):void
		{
			
			trace("e = " + e.state);
			if(e.state == "buffering")
			{
				showControlBar(true);
				_myload.visible = true;
			}
			else
			{
				_myload.visible = false;
				
				if(e.state == 'paused')
				{
					showControlBar(true);
					_bigPlayBtn.visible = true;
				}
				else
				{
					_bigPlayBtn.visible = false;
				}
				
				if(e.state == 'playing')
				{
					showControlBar(false);
				}
			}
			
			if(e.state == "ready")
			{
				_playBtn.visible = true;
				_stopBtn.visible = false;
				_bigPlayBtn.visible = true;
				reload();
				_vp.pause();
			}
			
		}
		
		private function showControlBar(value:Boolean):void
		{
			_vPlayerBar.visible =  value;
			_mainWindow.titleCon.visible = value;
		}
		
		private function vpDurationChangeHandler(e:TimeEvent):void
		{
			_duration = _vp.duration;
			updateDuration(_vp.duration);
		}
		
		private var _lastTime:Number = 0;
		private function vpCurrentTimeChangeHandler(e:TimeEvent):void
		{
			//trace("总时长 = " + _vp.duration, "当前时长 = " + _vp.currentTime);
			
			var currentTime:Number = _vp.currentTime;
			
			var videoSilderSeek:Number = (_videoSilderBnakSp.width / _vp.duration) * (currentTime - _lastTime);
			_lastTime = currentTime;
			
			updateNowTime(currentTime);
			updateVideoProgress(videoSilderSeek);
		}
		
		/**
		 *更新视频总时长 
		 * @param duration 时长
		 * 
		 */		
		public function updateDuration(duration:Number):void
		{
			var all_second:int = int(duration % 60);
			var all_minute:int = int(duration / 60);
			
			var timeLen:String = "";
				
			if(all_minute < 10)
			{
				if(all_second < 10)
				{
					timeLen += '0' + String(all_minute) + ':0' + String(all_second);
				}
				else
				{
					timeLen += '0' + String(all_minute) + ':' + String(all_second);
				}
			}
			else
			{
				if(all_second < 10)
				{
					timeLen += String(all_minute) + ':0' + String(all_second);
				}
				else
				{
					timeLen += String(all_minute) + ':' + String(all_second);
				}
			}
				
			//trace(timeLen + " / ");
			_sumDurationText.text = timeLen + " / ";
			
		}
		
		/**
		 *更新当前播放时间 
		 * @param nowTime
		 * 
		 */		
		public function updateNowTime(nowTime:Number):void
		{
			var now_second:int = int(nowTime % 60);
			var now_minute:int = int(nowTime / 60);
			
			var nowTimeLen:String = "";
			
			if(now_minute < 10)
			{
				if(now_second < 10)
				{
					nowTimeLen += '0' + String(now_minute) + ':0' + String(now_second);
				}
				else
				{
					nowTimeLen += '0' + String(now_minute) + ':' + String(now_second);
				}
			}
			else
			{
				if(now_second < 10)
				{
					nowTimeLen += String(now_minute) + ':0' + String(now_second);
				}
				else
				{
					nowTimeLen += String(now_minute) + ':' + String(now_second);
				}
			}
			
			//trace(nowTimeLen);
			_currentDurationText.text = nowTimeLen;
			
		}
		
		/**
		 *更新播放进度条进度 
		 * @param videoSilderSeek
		 * 
		 */		
		private function updateVideoProgress(videoSilderSeek:Number):void
		{
			//trace("videoSilderSeek = " + videoSilderSeek);
			_videoSilderFrontSp.width += videoSilderSeek;
			_videoSilderMiddleSp.width = _videoSilderFrontSp.width + 20;
			_videoSilderCircleSp.x = _videoSilderFrontSp.x + _videoSilderFrontSp.width;
		}
		
		public function resize(w:Number, h:Number):void
		{
			if(!_fullCcreenBtn.visible)
			{
				w = Screen.mainScreen.visibleBounds.width;
				h = Screen.mainScreen.visibleBounds.height;
			}
			else
			{
				w = stage.stageWidth;
				h = stage.stageHeight;
			}
			
			//trace('resize', w, h);
			
			_vPlayerBar.y = h - 50;
			_vPlayerBar.width = w - 2;
			
			this.graphics.beginFill(0xfff000, 0);
			this.graphics.drawRect(0, 0, w - 2, h);
			this.graphics.endFill();
			
			_mespri.graphics.beginFill(0xffffff, 0);
			_mespri.graphics.drawRect(0, 0, w - 2, h);
			_mespri.graphics.endFill();
			
			_mespri.width = w - 2;
			_mespri.height = h;
			
			_soundBtn.stage.scaleMode = StageScaleMode.NO_SCALE;
			//trace(width, height, _mespri.width, _mespri.height);
		}
	}
}