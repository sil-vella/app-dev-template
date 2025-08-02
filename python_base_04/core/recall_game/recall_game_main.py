"""
Recall Game Main Entry Point

This module serves as the main entry point for the Recall game backend,
initializing all components and integrating with the main system.
"""

from typing import Optional
from tools.logger.custom_logging import custom_log
from .models.game_state import GameStateManager
from .game_logic.game_logic_engine import GameLogicEngine
import time


class RecallGameMain:
    """Main orchestrator for the Recall game backend"""
    
    def __init__(self):
        self.app_manager = None
        self.websocket_manager = None
        self.game_state_manager = None
        self.game_logic_engine = None
        self._initialized = False
    
    def initialize(self, app_manager) -> bool:
        """Initialize the Recall game backend with the main app_manager"""
        try:
            self.app_manager = app_manager
            self.websocket_manager = app_manager.get_websocket_manager()
            
            if not self.websocket_manager:
                custom_log("❌ WebSocket manager not available for Recall game", level="ERROR")
                return False
            
            # Initialize core components
            self.game_state_manager = GameStateManager()
            self.game_logic_engine = GameLogicEngine()
            
            # Register Recall game handlers with the main WebSocket manager
            self._register_recall_handlers()
            
            self._initialized = True
            custom_log("✅ Recall Game backend initialized successfully")
            return True
            
        except Exception as e:
            custom_log(f"❌ Failed to initialize Recall Game backend: {str(e)}", level="ERROR")
            return False
    
    def _register_recall_handlers(self):
        """Register Recall game handlers with the main WebSocket manager"""
        if not self.websocket_manager:
            custom_log("Warning: WebSocket manager not available")
            return
        
        # Register Recall game handlers with the main WebSocket manager
        self.websocket_manager.register_handler('recall_join_game', self._handle_join_game)
        self.websocket_manager.register_handler('recall_leave_game', self._handle_leave_game)
        self.websocket_manager.register_handler('recall_player_action', self._handle_player_action)
        self.websocket_manager.register_handler('recall_call_recall', self._handle_call_recall)
        self.websocket_manager.register_handler('recall_play_out_of_turn', self._handle_play_out_of_turn)
        self.websocket_manager.register_handler('recall_use_special_power', self._handle_use_special_power)
        
        # Register room management handlers
        self.websocket_manager.register_handler('get_public_rooms', self._handle_get_public_rooms)
        
        custom_log("Recall game handlers registered with main WebSocket manager")
    
    def _handle_get_public_rooms(self, data):
        """Handle request for public rooms list"""
        try:
            session_id = data.get('session_id')
            
            if not session_id:
                self._emit_error(session_id, 'Session ID required')
                return False
            
            # Get all public rooms from the WebSocket manager's room manager
            if self.websocket_manager and hasattr(self.websocket_manager, 'room_manager'):
                all_rooms = self.websocket_manager.room_manager.get_all_rooms()
                
                # Filter for public rooms only
                public_rooms = []
                for room_id, room_info in all_rooms.items():
                    if room_info.get('permission') == 'public':
                        public_rooms.append({
                            'room_id': room_id,
                            'room_name': room_info.get('room_name', room_id),
                            'owner_id': room_info.get('owner_id'),
                            'permission': room_info.get('permission'),
                            'current_size': room_info.get('current_size', 0),
                            'max_size': room_info.get('max_size', 4),
                            'min_size': room_info.get('min_size', 2),
                            'created_at': room_info.get('created_at'),
                            'game_type': room_info.get('game_type', 'classic'),
                            'turn_time_limit': room_info.get('turn_time_limit', 30),
                            'auto_start': room_info.get('auto_start', True)
                        })
                
                # Send response
                self._emit_to_session(session_id, 'get_public_rooms_success', {
                    'success': True,
                    'data': public_rooms,
                    'count': len(public_rooms),
                    'timestamp': time.time()
                })
                
                custom_log(f"Sent {len(public_rooms)} public rooms to session {session_id}")
                return True
            else:
                # Fallback: return empty list if room manager not available
                self._emit_to_session(session_id, 'get_public_rooms_success', {
                    'success': True,
                    'data': [],
                    'count': 0,
                    'timestamp': time.time()
                })
                
                custom_log(f"Room manager not available, sent empty public rooms list to session {session_id}")
                return True
        
        except Exception as e:
            custom_log(f"Error in _handle_get_public_rooms: {str(e)}", level="ERROR")
            self._emit_error(session_id, f'Error getting public rooms: {str(e)}')
            return False
    
    def _handle_join_game(self, data):
        """Handle player joining a game"""
        # TODO: Implement game joining logic
        custom_log("Join game handler called")
        return True
    
    def _handle_leave_game(self, data):
        """Handle player leaving a game"""
        # TODO: Implement game leaving logic
        custom_log("Leave game handler called")
        return True
    
    def _handle_player_action(self, data):
        """Handle player action through declarative rules"""
        # TODO: Implement player action logic
        custom_log("Player action handler called")
        return True
    
    def _handle_call_recall(self, data):
        """Handle player calling Recall"""
        # TODO: Implement Recall calling logic
        custom_log("Call Recall handler called")
        return True
    
    def _handle_play_out_of_turn(self, data):
        """Handle out-of-turn card play"""
        # TODO: Implement out-of-turn play logic
        custom_log("Play out of turn handler called")
        return True
    
    def _handle_use_special_power(self, data):
        """Handle special power card usage"""
        # TODO: Implement special power logic
        custom_log("Use special power handler called")
        return True
    
    def _emit_to_session(self, session_id: str, event: str, data: dict):
        """Emit event to a specific session"""
        if self.websocket_manager:
            self.websocket_manager.send_to_session(session_id, event, data)
    
    def _emit_error(self, session_id: str, message: str):
        """Emit error to a specific session"""
        self._emit_to_session(session_id, 'recall_error', {'message': message})
    
    def get_websocket_manager(self):
        """Get the WebSocket manager"""
        return self.websocket_manager if self._initialized else None
    
    def get_game_state_manager(self) -> Optional[GameStateManager]:
        """Get the game state manager"""
        return self.game_state_manager if self._initialized else None
    
    def get_game_logic_engine(self) -> Optional[GameLogicEngine]:
        """Get the game logic engine"""
        return self.game_logic_engine if self._initialized else None
    
    def is_initialized(self) -> bool:
        """Check if the Recall game backend is initialized"""
        return self._initialized
    
    def health_check(self) -> dict:
        """Perform health check on Recall game components"""
        if not self._initialized:
            return {
                'status': 'not_initialized',
                'component': 'recall_game',
                'details': 'Recall game backend not initialized'
            }
        
        try:
            websocket_health = 'healthy' if self.websocket_manager else 'unhealthy'
            state_manager_health = 'healthy' if self.game_state_manager else 'unhealthy'
            logic_engine_health = 'healthy' if self.game_logic_engine else 'unhealthy'
            
            return {
                'status': 'healthy' if all([
                    websocket_health == 'healthy',
                    state_manager_health == 'healthy',
                    logic_engine_health == 'healthy'
                ]) else 'degraded',
                'component': 'recall_game',
                'details': {
                    'websocket_manager': websocket_health,
                    'game_state_manager': state_manager_health,
                    'game_logic_engine': logic_engine_health
                }
            }
            
        except Exception as e:
            return {
                'status': 'unhealthy',
                'component': 'recall_game',
                'details': f'Health check failed: {str(e)}'
            }
    
    def cleanup(self):
        """Clean up Recall game resources"""
        try:
            custom_log("✅ Recall Game backend cleaned up successfully")
            
        except Exception as e:
            custom_log(f"❌ Error cleaning up Recall Game backend: {str(e)}", level="ERROR")


# Global instance for easy access
_recall_game_main = None


def initialize_recall_game(app_manager) -> Optional[RecallGameMain]:
    """Initialize the Recall game backend"""
    global _recall_game_main
    
    try:
        _recall_game_main = RecallGameMain()
        success = _recall_game_main.initialize(app_manager)
        
        if success:
            custom_log("✅ Recall Game backend initialized successfully")
            return _recall_game_main
        else:
            custom_log("❌ Failed to initialize Recall Game backend", level="ERROR")
            return None
            
    except Exception as e:
        custom_log(f"❌ Error initializing Recall Game backend: {str(e)}", level="ERROR")
        return None


def get_recall_game_main() -> Optional[RecallGameMain]:
    """Get the global Recall game main instance"""
    return _recall_game_main


def get_recall_game_websocket_manager():
    """Get the Recall game WebSocket manager"""
    if _recall_game_main:
        return _recall_game_main.get_websocket_manager()
    return None


def get_recall_game_state_manager():
    """Get the Recall game state manager"""
    if _recall_game_main:
        return _recall_game_main.get_game_state_manager()
    return None


def get_recall_game_logic_engine():
    """Get the Recall game logic engine"""
    if _recall_game_main:
        return _recall_game_main.get_game_logic_engine()
    return None 