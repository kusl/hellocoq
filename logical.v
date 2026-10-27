Theorem or_comm : forall A B : Prop, A \/ B -> B \/ A.
Proof.
  intros A B H.
  destruct H as [HA | HB].
  - right. assumption.
  - left. assumption.
Qed.
