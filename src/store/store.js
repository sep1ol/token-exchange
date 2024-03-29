import { applyMiddleware, combineReducers, createStore } from "redux";
import { composeWithDevTools } from "redux-devtools-extension";
import { provider, tokens, exchange, giveAway } from "./reducers";
import thunk from "redux-thunk";

const reducer = combineReducers({
  provider,
  tokens,
  exchange,
  giveAway,
});

const initialState = {};

const middleware = [thunk];

const store = createStore(
  reducer,
  initialState,
  composeWithDevTools(applyMiddleware(...middleware))
);

export default store;
