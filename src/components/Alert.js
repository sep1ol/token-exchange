import { useEffect, useRef } from "react";
import { useDispatch, useSelector } from "react-redux";
import config from "../config.json";
import closeButton from "../assets/close-white.svg";

import { myEventsSelector } from "../store/selectors";
import { removeRepeatedAlerts } from "../store/interactions";

const Alert = () => {
  const dispatch = useDispatch();
  const alertRef = useRef(null);

  const account = useSelector((state) => state.provider.account);
  const network = useSelector((state) => state.provider.network);
  const events = useSelector(myEventsSelector);

  const isPending = useSelector(
    (state) => state.exchange.transaction.isPending
  );
  const isSuccessful = useSelector(
    (state) => state.exchange.transaction.isSuccessful
  );
  const isError = useSelector((state) => state.exchange.transaction.isError);

  const contractErrorMessage = useSelector(
    (state) => state.exchange.contractErrorMessage
  );

  const removeAlertHandler = () => {
    alertRef.current.className = "alert alert--remove";
    dispatch({ type: "RESET_ALERT" });
  };

  useEffect(() => {
    if (alertRef.current !== null) {
      removeRepeatedAlerts(
        isSuccessful,
        isPending,
        isError,
        account,
        alertRef,
        events
      );
    }
  }, [isPending, isSuccessful, isError, account, events]);

  return (
    <div>
      {isPending ? (
        <div
          ref={alertRef}
          onClick={removeAlertHandler}
          className="alert alert--remove"
        >
          <h1>Transaction Pending...</h1>
          <img src={closeButton} alt="close" className="button--close" />
        </div>
      ) : isSuccessful && events[0] ? (
        <div
          ref={alertRef}
          onClick={removeAlertHandler}
          className="alert alert--remove"
        >
          <h1>Transaction Successful</h1>
          <a
            href={
              config[network]
                ? `${config[network].explorerUrl}/tx/${events[0].transactionHash}`
                : "#"
            }
            target="_blank"
            rel="noreferrer"
          >
            {events[0] &&
              `${events[0].transactionHash.slice(
                0,
                6
              )}...${events[0].transactionHash.slice(-6)}`}
          </a>
          <img src={closeButton} alt="close" className="button--close" />
        </div>
      ) : isError ? (
        <div
          ref={alertRef}
          onClick={removeAlertHandler}
          className="alert alert--remove"
        >
          {contractErrorMessage ? (
            <h1>{contractErrorMessage}</h1>
          ) : (
            <h1>Transaction Will Fail</h1>
          )}

          <img src={closeButton} alt="close" className="button--close" />
        </div>
      ) : (
        // No transaction happening
        <span></span>
      )}

      {/* <div className="alert alert--remove"></div> */}
    </div>
  );
};

export default Alert;
